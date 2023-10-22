App = m.comp do
   oninit: !->
      @ent = void
      @val = ""

   oncreate: !->
      os.addListener \ents (ents) ~>
         @ent = ents.0
         @val = await os.readFile @ent
         m.redraw!

   onchageVal: (event) !->
      @val = event.target.value

   view: ->
      m \.column.h-100,
         m \.col-0,
            m Menubar,
               menus:
                  *  text: "Tệp tin"
                     items:
                        *  text: "Tạo mới"
                        *  text: "Mở tập tin..."
                        ,,
                        *  text: "Đóng"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
                  *  text: "Chỉnh sửa"
                     items:
                        *  text: "Cắt"
                  *  text: "Thông tin"
         m \.col.p-1,
            m Textarea,
               class: "h-100"
               fill: yes
               value: @val
               onchange: @onchageVal
