App = m.comp do
   oninit: !->
      @ent = os.args.ent
      @vapps = osTask.getVapps!
      @appName = void

   oncreate: !->
      os.fitContentSize!

   onItemClickMenu: (item) !->
      @appName = item.value

   onclickOk: (event) !->
      vapp = @vapps.find (.name == @appName)
      os.close vapp

   onclickCancel: (event) !->
      os.close!

   view: ->
      m \.column.gap-3.h-100.p-3,
         m \.col.ov-auto,
            m Menu,
               fill: yes
               basic: yes
               compact: yes
               activeItemClass: "bg-blue2 text-white"
               value: @appName
               onItemClick: @onItemClickMenu
               items: @vapps.map (vapp) ~>
                  text: vapp.name
                  icon: vapp.icon
                  value: vapp.name
         m \.col-0,
            m Checkbox,
               "Luôn mở phần mở rộng \".#{@ent.ext}\" với ứng dụng này"
         m \.col-0.text-right,
            m InputGroup,
               m Button,
                  width: 80
                  color: \blue
                  disabled: @appName == void
                  onclick: @onclickOk
                  "OK"
               m Button,
                  width: 80
                  onclick: @onclickCancel
                  "Hủy"
