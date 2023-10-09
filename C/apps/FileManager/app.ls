await os.import do
   \filesize@9.0.11

App = m.comp do
   oninit: !->
      @isDesktop = os.args.isDesktop
      @viewType = os.args.viewType or \list
      @sortedBy = os.args.sortedBy or \name
      @sortedOrder = os.args.sortedOrder or 1
      @path = os.args.path or \/

      @dir = void
      @ents = []
      @selEnts = []
      @selData = void
      @selector = void
      @hist = os.createHist!

   oncreate: !->
      @selector.dom.hidden = yes
      await @goPath @path
      m.redraw!

   goPath: (path, dontPushHist) !->
      path = os.absPath path
      @ents = await os.readDir path
      @sortEnts!
      @path = path
      unless dontPushHist
         @hist.push path
      m.redraw!

   sortEnts: !->
      @ents.sort (entA, entB) ~>
         if val = entB.isDir - entA.isDir
            return val
         val = switch @sortedBy
            | \name => entA.name.localeCompare entB.name
            | \size => entA.size - entB.size
            | \type => entA.ext.localeCompare entB.ext
            | \mtime => entA.mtime - entB.mtime
         if val
            return val * @sortedOrder
         entryA.name.localeCompare entB.name

   openEnt: (ent) !->
      if ent.isDir
         @goPath ent.path

   onclickBack: (event) !->
      path = @hist.back!
      @goPath path, yes

   onclickForward: (event) !->
      path = @hist.forward!
      @goPath path, yes

   onclickGoParent: (event) !->
      path = os.dirPath @dir.path
      @goPath path

   onsubmitForm: (event) !->
      event.preventDefault!
      @goPath @path

   onchangePath: (event) !->
      @path = event.target.value

   onpointerdownEnts: (event) !->
      if event.target == event.currentTarget
         @selEnts = []
         if event.buttons == 1
            entsRect = event.currentTarget.getBoundingClientRect!
            mouseX = event.x - entsRect.x
            mouseY = event.y - entsRect.y
            @selData =
               x: mouseX
               y: mouseY

   onpointermoveEnts: (event) !->
      event.redraw = no
      if @selData
         if @selector.dom.hidden
            event.currentTarget.setPointerCapture event.pointerId
            @selector.dom.hidden = no
         entsRect = event.currentTarget.getBoundingClientRect!
         mouseX = event.x - entsRect.x
         mouseY = event.y - entsRect.y
         selX1 = Math.min @selData.x, mouseX
         selY1 = Math.min @selData.y, mouseY
         selX2 = Math.max @selData.x, mouseX
         selY2 = Math.max @selData.y, mouseY
         entEls = @dom.querySelectorAll "[data-i]"
         @selEnts = []
         for entEl in entEls
            entRect = entEl.getBoundingClientRect!
            entX1 = entRect.x - entsRect.x
            entY1 = entRect.y - entsRect.y
            entX2 = entRect.right - entsRect.x
            entY2 = entRect.bottom - entsRect.y
            unless selX1 >= entX2 or selX2 <= entX1 or selY1 >= entY2 or selY2 <= entY1
               ent = @ents[entEl.dataset.i]
               @selEnts.push ent
         @selector.dom.style <<< m.style do
            left: selX1
            top: selY1
            width: selX2 - selX1
            height: selY2 - selY1
         m.redraw!

   onpointerupEnts: (event) !->
      if @selector.dom.hidden
         @selData = void

   onlostpointercaptureEnts: (event) !->
      if @selData
         @selData = void
         @selector.dom.hidden = yes

   onclickEnt: (ent, event) !->
      @selEnts = [ent]
      if event.detail % 2 == 0
         @openEnt ent

   oncontextmenuEnt: (ent, event) !->
      unless @selEnts.includes ent
         @selEnts = [ent]
      os.addContextMenu event,
         *  text: "Mở"
            click: !~>
               @openEnt ent
         ,,
         *  text: "Đổi tên"
            icon: \pen-field
         *  text: "Xóa"
            icon: \trash
            color: \red

   view: ->
      m \.column.h-100,
         unless @isDesktop
            m \.col-0.row.gap-3.p-3,
               m InputGroup,
                  m Button,
                     disabled: !@hist.canGoBack
                     icon: \arrow-left
                     onclick: @onclickBack
                  m Button,
                     disabled: !@hist.canGoForward
                     icon: \arrow-right
                     onclick: @onclickForward
                  m Button,
                     disabled: @dir == void or @dir.path == \/
                     icon: \arrow-up
                     onclick: @onclickGoParent
               m \form.col,
                  onsubmit: @onsubmitForm
                  m InputGroup,
                     fill: yes
                     m TextInput,
                        value: @path
                        onchange: @onchangePath
                     m Button,
                        icon: \arrow-rotate-right
                     m Button,
                        type: \submit
                        icon: \arrow-turn-down-left
         m \.col.relative.ov-hidden,
            switch @viewType
            | \list
               m Table,
                  class:
                     "h-100 p-3"
                     "pt-0": !@isDesktop
                  striped: yes
                  interactive: yes
                  onpointerdown: @onpointerdownEnts
                  onpointermove: @onpointermoveEnts
                  onpointerup: @onpointerupEnts
                  onlostpointercapture: @onlostpointercaptureEnts
                  m \thead,
                     m \tr,
                        m \th.col-6,
                           "Tên"
                        m \th.col-2,
                           "Kích thước"
                        m \th.col-4,
                           "Ngày sửa đổi"
                  m \tbody,
                     @ents.map (ent, i) ~>
                        m \tr,
                           key: ent.path
                           class: m.class do
                              "bg-blue3": @selEnts.includes ent
                           "data-i": i
                           onclick: @onclickEnt.bind void ent
                           oncontextmenu: @oncontextmenuEnt.bind void ent
                           m \td,
                              ent.name
                           m \td,
                              filesize ent.size
                           m \td,
                              dayjs ent.mtime .format "DD/MM/YYYY HH:mm"
            @selector =
               m \.absolute.border.border-blue2.bg-blue2.bg-opacity-25.pe-none.z-10
