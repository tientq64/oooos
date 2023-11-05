window.require =
   paths:
      vs: \https://cdn.jsdelivr.net/npm/monaco-editor@0.44.0/min/vs

await os.import do
   \monaco-editor@0.44.0/min/vs/loader.js

await os.import do
   \monaco-editor@0.44.0/min/vs/editor/editor.main.css
   \monaco-editor@0.44.0/min/vs/editor/editor.main.nls.js
   \monaco-editor@0.44.0/min/vs/editor/editor.main.js

App = m.comp do
   oninit: !->
      @editor = void
      @tabs = []
      @tab = void
      @model = void
      @languages =
         js: \javascript
         css: \css
         html: \html

   oncreate: !->
      @editor = monaco.editor.create @editorEl.dom,
         *  theme: \vs-dark
            tabSize: 3
            wordWrap: \on
            fontFamily: "D2Coding, monospace"
            fontSize: 16
            smoothScrolling: yes
            automaticLayout: yes
            minimap:
               enabled: yes
               renderCharacters: no
            contextmenu: no
      @editor.addCommand monaco.KeyMod.CtrlCmd + monaco.KeyCode.KeyS, !~>
         @saveTab!
      @editor.onContextMenu (editorEvent) !~>
         {event, target} = editorEvent
         {MouseTargetType} = monaco.editor
         if target.type in [MouseTargetType.CONTENT_EMPTY, MouseTargetType.CONTENT_TEXT]
            os.addContextMenu event.browserEvent,
               *  text: "Cắt"
                  icon: \scissors
                  label: "Ctrl+X"
                  click: !~>
                     @editor.focus!
                     @editor.trigger \app \editor.action.clipboardCutAction
               *  text: "Sao chép"
                  icon: \copy
                  label: "Ctrl+C"
                  click: !~>
                     @editor.focus!
                     @editor.trigger \app \editor.action.clipboardCopyAction
               *  text: "Dán"
                  icon: \paste
                  label: "Ctrl+V"
                  click: !~>
                     @editor.focus!
                     @editor.trigger \app \editor.action.clipboardPasteAction
               ,,
               *  text: "Chọn tất cả"
                  label: "Ctrl+A"
                  click: !~>
                     @editor.focus!
                     @editor.trigger \app \editor.action.selectAll
               ,,
               *  text: "Bảng lệnh..."
                  icon: \terminal
                  label: "F1"
                  click: !~>
                     @editor.focus!
                     @editor.trigger \app \editor.action.quickCommand

      os.addListener \ents (ents) !~>
         for ent in ents
            if ent.isFile
               @newTab ent

      @newTab!

   newTab: (ent, language) !->
      tab =
         id: os.randomUuid!
         ent: ent
         title: ent?name or "Không có tiêu đề"
         model: void
         viewState: void
      @tabs.push tab
      @setTab tab
      m.redraw!
      if ent
         val = await os.readFile ent
         language ?= @languages[ent.ext]
      tab.model = monaco.editor.createModel val, language
      if tab == @tab
         @setTab tab, yes
      m.redraw!

   setTab: (tab, force) !->
      if tab != @tab or force
         if @tab
            @tab.viewState = @editor.saveViewState!
         @tab = tab
         if tab
            @model = tab.model
            @editor.setModel @model
            @editor.restoreViewState tab.viewState
            @editor.focus!
         else
            @model = void
            @editor.setModel!
         m.redraw!

   saveTab: (tab = @tab) !->
      if tab.model
         if tab.ent
            val = tab.model.getValue!
            await os.writeFile tab.ent, val
         m.redraw!

   closeTab: (tab = @tab) !->
      index = @tabs.indexOf tab
      if index >= 0
         if tab.model
            tab.model.dispose!
         @tabs.splice index, 1
         if tab == @tab
            nextTab = @tabs[index] or @tabs[index - 1]
            @setTab nextTab
         m.redraw!

   ondblclickTabs: (event) !->
      if event.target == event.currentTarget
         @newTab!

   oncontextmenuTabs: (event) !->
      if event.target == event.currentTarget
         os.addContextMenu event,
            *  text: "Tập tin mới"
               icon: \file
               click: !~>
                  @newTab!

   onclickTab: (tab, event) !->
      @setTab tab
      @editor.focus!

   oncontextmenuTab: (tab, event) !->
      os.addContextMenu event,
         *  text: "Đóng tab"
            icon: \xmark
            click: !~>
               @closeTab tab
         *  text: "Đóng các tab khác"
            click: !~>
               for tab2 in @tabs.slice 0
                  unless tab2 == tab
                     @closeTab tab2
         *  text: "Đóng tất cả tab"
            click: !~>
               for tab2 in @tabs.slice 0
                  @closeTab tab2

   onclickCloseTab: (tab, event) !->
      event.stopPropagation!
      @closeTab tab

   view: ->
      m \.column.h-100.dark,
         m \.col-0.border-b,
            m Menubar,
               menus:
                  *  text: "Tệp tin"
                     subitems:
                        *  text: "Tập tin mới"
                           icon: \file
                           click: !~>
                              @newTab!
                        *  text: "Mở tập tin..."
                        ,,
                        *  text: "Lưu"
                           icon: \floppy-disk
                           label: "Ctrl+S"
                           enabled: @model
                           click: !~>
                              @saveTab!
                        ,,
                        *  text: "Thoát"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
                  *  text: "Chỉnh sửa"
                     subitems:
                        *  text: "Cắt"
                           icon: \scissors
                           label: "Ctrl+X"
                           enabled: @model
                           click: !~>
                              @editor.focus!
                              @editor.trigger \app \editor.action.clipboardCutAction
                        *  text: "Sao chép"
                           icon: \copy
                           label: "Ctrl+C"
                           enabled: @model
                           click: !~>
                              @editor.focus!
                              @editor.trigger \app \editor.action.clipboardCopyAction
                        *  text: "Dán"
                           icon: \paste
                           label: "Ctrl+V"
                           enabled: @model
                           click: !~>
                              @editor.focus!
                              @editor.trigger \app \editor.action.clipboardPasteAction
                        ,,
                        *  text: "Chọn tất cả"
                           label: "Ctrl+A"
                           enabled: @model
                           click: !~>
                              @editor.focus!
                              @editor.trigger \app \editor.action.selectAll
                  *  text: "Xem"
                     subitems:
                        *  text: "Bảng lệnh..."
                           icon: \terminal
                           label: "F1"
                           enabled: @model
                           click: !~>
                              @editor.focus!
                              @editor.trigger \app \editor.action.quickCommand
                        ,,
                        *  text: "Toàn màn hình"
                           icon: \expand-wide
                           label: "F11"
                           click: !~>
                              os.setFullscreen!
                        ,,
                        *  text: "Ngắt dòng"
                  *  text: "Đi đến"
                     subitems:
                        *  text: "Đi đến dòng/cột..."
                           icon: \colon
                           label: "Ctrl+G"
                           enabled: @model
                  *  text: "Thông tin"
                     subitems:
                        *  text: "Thông tin ứng dụng"
                           icon: \circle-info
         m \.col.row,
            m \.col-0.border-r,
               style: m.style do
                  width: 300
               "Explorer"
            m \.col.column,
               m \.col-0.row.ov-x-auto.text-nowrap,
                  ondblclick: @ondblclickTabs
                  oncontextmenu: @oncontextmenuTabs
                  @tabs.map (tab) ~>
                     m \.row.middle.px-3.py-1.text-6.text-gray2,
                        key: tab.id
                        class: m.class do
                           "bg-gray1 text-white": tab == @tab
                        onclick: @onclickTab.bind void tab
                        oncontextmenu: @oncontextmenuTab.bind void tab
                        m \div,
                           class: m.class do
                              "text-italic": !tab.ent
                           tab.title
                        m Button,
                           class: "ml-2"
                           style:
                              borderRadius: 2
                           width: 16
                           height: 16
                           basic: yes
                           small: yes
                           color: \red
                           icon: \xmark
                           onclick: @onclickCloseTab.bind void tab
               @editorEl =
                  m \.col
