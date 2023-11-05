App = m.comp do
   oninit: !->
      @ent = void
      @val = ""
      @modified = no

   oncreate: !->
      os.addListener \ents (ents) !~>
         @ent = ents.0
         @val = await os.readFile @ent
         m.redraw!

      os.addListener \$close ~>
         if @modified
            result = await os.confirm "Sửa đổi chưa được lưu, lưu lại trước khi đóng?" yes
            switch result
            | yes => await @save!
            | void => no

   save: !->
      if @ent
         await os.writeFile @ent, @val
      @modified = no
      m.redraw!

   onchageVal: (event) !->
      @modified = yes
      @val = event.target.value

   view: ->
      m \.column.gap-1.p-1.h-100,
         m \.col-0,
            m Menubar,
               menus:
                  *  text: "Tệp tin"
                     subitems:
                        *  text: "Tạo mới"
                        *  text: "Mở tập tin..."
                        ,,
                        *  text: "Lưu"
                           icon: \floppy-disk
                           click: !~>
                              @save!
                        ,,
                        *  text: "Thoát"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
                  *  text: "Chỉnh sửa"
                     subitems:
                        *  text: "Cắt"
                  *  text: "Thông tin"
         m \.col,
            m Textarea,
               class: "h-100"
               fill: yes
               autoFocus: yes
               value: @val
               onchange: @onchageVal
