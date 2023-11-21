await os.import do
   \@fancyapps/ui@5.0.25/dist/panzoom/panzoom.umd.min.js
   \@fancyapps/ui@5.0.25/dist/panzoom/panzoom.toolbar.umd.min.js
   \@fancyapps/ui@5.0.25/dist/panzoom/panzoom.min.css
   \@fancyapps/ui@5.0.25/dist/panzoom/panzoom.toolbar.min.css

App = m.comp do
   oninit: !->
      @ent = void
      @panzoom = void
      @dataUrl = void
      @loaded = no

   oncreate: !->
      @initPanzoom!
      os.addListener \ents @onEnts

   initPanzoom: !->
      @panzoom = new Panzoom @panzoomVnode.dom,
         *  click: \toggleCover
            maxScale: 1
            on:
               afterLoad: !~>
                  @loaded = yes
                  m.redraw!
               error: !~>
                  @loaded = no
                  os.setFullscreen no
                  m.redraw!
               enterFS: !~>
                  os.setFullscreen yes
               exitFS: !~>
                  os.setFullscreen no
         *  Toolbar: Toolbar

   showAppInfo: !->
      os.alert do
         """
            **Tên:** ImageViewer

            **Các thư viện được sử dụng:**
            -  [@fancyapps/ui@5.0.25](https://fancyapps.com/panzoom/)
         """
         isMarkdown: yes

   onEnts: (ents) !->
      @ent = ents?0
      @dataUrl = void
      @loaded = no
      m.redraw!
      if @ent.isFile
         @dataUrl = await os.readFile @ent, \dataUrl
         m.redraw!
      @panzoom.updateMetrics!

   onremove: !->
      @panzoom.destroy!

   view: ->
      m \.column.h-100p,
         m \.col-0.p-1,
            m Menubar,
               menus:
                  *  text: "Tệp"
                     subitems:
                        *  text: "Mở hình ảnh..."
                        ,,
                        *  text: "Thoát"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
                  *  text: "Xem"
                     subitems:
                        *  text: "Toàn màn hình"
                           icon: \expand-wide
                           enabled: @loaded
                           click: !~>
                              @panzoom.toggleFS!
                        ,,
                        *  text: "Phóng to"
                           icon: \magnifying-glass-plus
                           enabled: @loaded and @panzoom.canZoomIn!
                           click: !~>
                              @panzoom.zoomIn!
                        *  text: "Thu nhỏ"
                           icon: \magnifying-glass-minus
                           enabled: @loaded and @panzoom.canZoomOut!
                           click: !~>
                              @panzoom.zoomOut!
                        ,,
                        *  text: "Xoay trái 90 độ"
                           icon: \rotate-left
                           enabled: @loaded
                           click: !~>
                              @panzoom.rotateCCW!
                        *  text: "Xoay phải 90 độ"
                           icon: \rotate-right
                           enabled: @loaded
                           click: !~>
                              @panzoom.rotateCW!
                        ,,
                        *  text: "Lật dọc"
                           icon: \arrows-left-right
                           enabled: @loaded
                           click: !~>
                              @panzoom.flipX!
                        *  text: "Lật ngang"
                           icon: \arrows-up-down
                           enabled: @loaded
                           click: !~>
                              @panzoom.flipY!
                        ,,
                        *  text: "Đặt lại chế độ xem"
                           icon: \rotate
                           click: !~>
                              @panzoom.reset!
                  *  text: "Tùy chọn"
                     subitems:
                        *  text: "Đặt làm hình nền desktop"
                           icon: \image-landscape
                           enabled: @loaded
                           click: !~>
                              os.setDesktopBgImagePath @ent.path
                  *  text: "Trợ giúp"
                     subitems:
                        *  text: "Thông tin ứng dụng"
                           icon: \circle-info
                           click: !~>
                              @showAppInfo!
         @panzoomVnode =
            m \.col.f-panzoom.bg-gray0,
               m \img.f-panzoom__content,
                  src: @dataUrl
