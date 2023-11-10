await os.import do
   \livescript2@1.5.0
   \sky:table@6.8.1
   \filesize@9.0.11

App = m.comp do
   oninit: !->
      @path = os.absPath os.args.path ? \/

      @input = ""
      @lines = []

      @help.toString = @help

   oncreate: !->
      @exec "path"

   cd: (path) ->
      if path
         path = os.joinPath @path, path
         dir = await os.getEnt path
         if dir.isDir
            @path = dir.path
         else
            throw Error "Không phải thư mục"
      @path

   ls: (path) ->
      path ?= @path
      path = os.joinPath \/ @path, path
      ents = await os.readDir path
      ents.sort (entA, entB) ~>
         if val = entB.isDir - entA.isDir
            return val
         entA.name.localeCompare entB.name
      @makeTable do
         *  "Tên"
            "Kích thước"
            "Ngày sửa đổi"
         ents.map (ent) ~>
            *  ent.name
               ent.isFile and filesize ent.size or \-
               dayjs ent.mtime .format "DD/MM/YYYY HH:mm"

   tasks: ->
      await os.requestPerm \tasksView
      @makeTable do
         *  "Tên"
            "Pid"
            "Loại"
            "Đường dẫn"
         os.tasks.map (task) ~>
            *  task.name
               task.pid
               task.type
               task.path

   run: (name, env) ->
      os.runTask name, env

   kill: (pid) ->
      os.closeTask pid

   exit: (val) ->
      os.close val

   exec: (input) !->
      input = String input .trim!
      if input
         line =
            id: os.randomUuid!
            input: input
            output: void
            error: void
            isWait: yes
            isError: no
         @lines.push line
         @input = ""
         @scrollToBottom!
         m.redraw!
         code = "->> #input"
         try
            code = livescript.compile code, bare: yes
            code = code
               .trim!
               .replace \{ "$& with(this){"
               .replace /^  var .+$/m ""
               .replace /\}\);$/ "}$&"
            func = eval code
            output = await func.call @
            line.output = output
         catch
            line.error = e
            line.isError = yes
         line.isWait = no
         @scrollToBottom!
         m.redraw!

   help: (funcName) ->
      """
         cd path?
            Thay đổi thư mục hiện tại.
         ls path?
            Hiển thị danh sách các mục trong thư mục.
         exec input
            Thực thi câu lệnh.
         help funcName?
            Hiển thị tài liệu hướng dẫn.
         exit val?
            Thoát ứng dụng.
      """

   makeTable: (headerCols, rows) ->
      data = [headerCols, ...rows]
      table.table data,
         border: table.getBorderCharacters \void
         columnDefault:
            paddingLeft: 0
            paddingRight: 3
         drawHorizontalLine: ~>

   scrollToBottom: !->
      setTimeout !~>
         @linesVnode.dom.scrollTop = @linesVnode.dom.scrollHeight
      , 10

   onsubmitInputForm: (event) !->
      event.preventDefault!
      @exec @input

   onchangeInput: (event) !->
      @input = event.target.value

   view: ->
      m \.column.h-100.bg-black,
         @linesVnode =
            m \.col.column.gap-2.p-3.ov-auto.font-mono.text-pre-wrap.scroll-smooth.select-text,
               @lines.map (line) ~>
                  m \div,
                     key: line.id
                     m \.text-green2,
                        line.input
                     switch
                     | line.isWait
                        m \.text-yellow2,
                           "..."
                     | line.isError
                        m \.text-red2,
                           String line.error
                     else
                        m \.text-white,
                           String line.output
         m \form.col-0.p-3.pt-0,
            onsubmit: @onsubmitInputForm
            m InputGroup,
               fill: yes
               m TextInput,
                  class: "font-mono"
                  autoFocus: yes
                  value: @input
                  onchange: @onchangeInput
               m Button,
                  type: \submit
                  icon: \arrow-turn-down-left
