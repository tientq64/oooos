await os.import do
   \filesize@9.0.11

App = m.comp do
   oninit: !->
      @isDesktop = os.args.isDesktop
      @path = os.args.path or \/
      @viewType = os.args.viewType or \list
      @sortedBy = os.args.sortedBy or \name
      @sortedOrder = os.args.sortedOrder or 1

      @dir = void
      @ents = []
      @selEnts = []
      @selData = void
      @selector = void
      @hist = os.createHist!
      @isShowDesktopIcons = yes

   oncreate: !->
      @selector.dom.hidden = yes
      await @goPath @path
      if @isDesktop
         os.requestTaskPerm \taskbarView
         os.requestTaskPerm \desktopBgView
      m.redraw!

   goPath: (path, dontPushHist) !->
      path = os.absPath path
      dir = await os.getEnt path
      ents = await os.readDir dir
      @dir = dir
      @ents = ents
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
            | \ext => entA.ext.localeCompare entB.ext
            | \mtime => entA.mtime - entB.mtime
         if val
            return val * @sortedOrder
         entA.name.localeCompare entB.name

   refresh: !->
      @goPath @path, yes

   openEnt: (ent, appName) !->
      if ent.isDir and !@isDesktop
         @goPath ent.path
      else
         os.openEnt ent, appName

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

   oncontextmenuEnts: (event) !->
      if event.target == event.currentTarget
         os.addContextMenu event,
            *  text: "Hiển thị"
               icon: \grid-2
               subitems:
                  *  text: "Biểu tượng"
                     icon: \circle-small if @viewType in [\icons \desktop]
                  *  text: "Danh sách"
                     icon: \circle-small if @viewType == \list
                     visible: !@isDesktop
                  ,,
                  *  text: "Hiện các icon trên desktop"
                     icon: \check if @isShowDesktopIcons
                     click: !~>
                        != @isShowDesktopIcons
            *  text: "Sắp xếp"
               icon: \arrow-up-arrow-down
               subitems:
                  *  text: "Tên"
                     icon: \circle-small if @sortedBy == \name
                     click: !~>
                        @sortedBy = \name
                        @sortEnts!
                  *  text: "Kích thước"
                     icon: \circle-small if @sortedBy == \size
                     click: !~>
                        @sortedBy = \size
                        @sortEnts!
                  *  text: "Loại"
                     icon: \circle-small if @sortedBy == \ext
                     click: !~>
                        @sortedBy = \ext
                        @sortEnts!
                  *  text: "Ngày sửa đổi"
                     icon: \circle-small if @sortedBy == \mtime
                     click: !~>
                        @sortedBy = \mtime
                        @sortEnts!
                  ,,
                  *  text: "Tăng dần"
                     icon: \circle-small if @sortedOrder == 1
                     click: !~>
                        @sortedOrder = 1
                        @sortEnts!
                  *  text: "Giảm dần"
                     icon: \circle-small if @sortedOrder == -1
                     click: !~>
                        @sortedOrder = -1
                        @sortEnts!
            *  text: "Làm mới"
               icon: \arrow-rotate-right
               click: !~>
                  @refresh!
            ,,
            *  text: "Tạo mới"
               icon: \plus
               subitems:
                  *  text: "Thư mục"
                     icon: \folder
                  *  text: "Lối tắt"
                     icon: \square-arrow-up-right
                  ,,
                  *  text: "Tập tin"
                     icon: \file
            ,,
            *  text: "Mở Terminal tại đây"
               icon: \fad:terminal
               click: !~>
                  os.runTask \Terminal,
                     args:
                        path: @dir.path
            ,,
            *  text: "Thông tin chi tiết"
               icon: \circle-info

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
         *  text: "Mở bằng"
            subitems:
               *  text: "Chọn ứng dụng khác"
         ,,
         *  text: "Đặt làm hình nền desktop"
            icon: \image-landscape
            visible: ent.ext in <[jpg png webp]>
            click: !~>
               os.setDesktopBgImagePath ent.path
         ,,
         *  text: "Cắt"
            icon: \scissors
         *  text: "Sao chép"
            icon: \copy
         ,,
         *  text: "Đổi tên"
            icon: \pen-field
         *  text: "Xóa"
            icon: \trash
            color: \red
         ,,
         *  text: "Thông tin chi tiết"
            icon: \circle-info

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
                  class: "h-100 p-3"
                  striped: yes
                  interactive: yes
                  onpointerdown: @onpointerdownEnts
                  onpointermove: @onpointermoveEnts
                  onpointerup: @onpointerupEnts
                  onlostpointercapture: @onlostpointercaptureEnts
                  oncontextmenu: @oncontextmenuEnts
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
                              m Icon,
                                 class: "mr-2"
                                 name: ent.icon
                              ent.name
                           m \td,
                              ent.isFile and filesize ent.size or \-
                           m \td,
                              dayjs ent.mtime .format "DD/MM/YYYY HH:mm"
            | \desktop
               m \.grid.gap-1.h-100.p-3.bg-center.bg-no-repeat.bg-black,
                  style: m.style do
                     paddingTop: os.taskbarHeight + 12 if os.taskbarPosition == \top
                     paddingBottom: os.taskbarHeight + 12 if os.taskbarPosition == \bottom
                     gridTemplateRows: "repeat(auto-fill, minmax(100px, 1fr))"
                     gridAutoColumns: 120
                     gridAutoFlow: \column
                     backgroundImage: "url(#that)" if os.desktopBgImageDataUrl
                  onpointerdown: @onpointerdownEnts
                  onpointermove: @onpointermoveEnts
                  onpointerup: @onpointerupEnts
                  onlostpointercapture: @onlostpointercaptureEnts
                  oncontextmenu: @oncontextmenuEnts
                  if @isShowDesktopIcons
                     @ents.map (ent, i) ~>
                        m \.column.center.middle.gap-2.rounded.text-center.text-white,
                           key: ent.path
                           class: m.class do
                              "bg-blue3 bg-opacity-50": @selEnts.includes ent
                           "data-i": i
                           onclick: @onclickEnt.bind void ent
                           oncontextmenu: @oncontextmenuEnt.bind void ent
                           m Icon,
                              name: ent.icon
                              size: 32
                           m \.w-100.truncate,
                              ent.name
            @selector =
               m \.absolute.border.border-blue2.bg-blue2.bg-opacity-25.pe-none.z-10
