await os.import do
   \livescript2@1.5.0
   \sky:table@6.8.1
   \filesize@9.0.11

App = m.comp do
   oninit: !->
      @path = os.args.path or \/

      @input = ""
      @lines = []

   oncreate: !->
      @execInput "path"
      @execInput "ls \\C"

   execInput: (input) !->
      input .= trim!
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

   cd: (path = "") ->
      path = os.joinPath @path, path
      dir = await os.getEnt path
      if dir.isDir
         @path = dir.path
      else
         throw Error "Không phải thư mục"
      @path

   ls: (path) ->
      path ?= @path
      ents = await os.readDir path
      data =
         *  "Tên"
            "Kích thước"
            "Ngày sửa đổi"
         ...ents.map (ent) ~>
            *  ent.name
               filesize ent.size
               dayjs ent.mtime .format "DD/MM/YYYY HH:mm"
      table.table data,
         border: table.getBorderCharacters \void
         columnDefault:
            paddingLeft: 0
            paddingRight: 3
         drawHorizontalLine: ~>

   scrollToBottom: !->
      requestAnimationFrame !~>
         @linesVnode.dom.scrollTop = @linesVnode.dom.scrollHeight

   onsubmitInputForm: (event) !->
      event.preventDefault!
      @execInput @input

   onchangeInput: (event) !->
      @input = event.target.value

   view: ->
      m \.column.gap-3.h-100.p-3.dark,
         @linesVnode =
            m \.col.column.gap-2.rounded.ov-overlay.font-mono.text-pre-wrap.select-text,
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
         m \form.col-0,
            onsubmit: @onsubmitInputForm
            m InputGroup,
               fill: yes
               m TextInput,
                  class: "font-mono"
                  value: @input
                  onchange: @onchangeInput
               m Button,
                  type: \submit
                  icon: \arrow-turn-down-left
