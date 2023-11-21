App = m.comp do
   oncreate: !->
      os.fitContentSize!

   onclickMoreSetting: (event) !->
      os.runTask \Settings

   onValueChangeBrightness: (val) !->
      os.setBrightness val

   onchangeNightLight: (event) !->
      os.setNightLight event.target.checked

   view: ->
      m \.column.gap-3.h-100p.p-3.pt-2,
         m \.row.between.middle.gap-3,
            m \h4,
               "Thông báo"
            m Button,
               basic: yes
               color: \red
               "Xóa hết thông báo"
         m \.col.column.center.middle.gap-3.text-gray2,
            m Icon,
               size: 32
               name: \message-smile
            "Không có thông báo nào"
         m \.row.between.middle.gap-3,
            m \h4,
               "Cài đặt nhanh"
            m Button,
               basic: yes
               onclick: @onclickMoreSetting
               "Các cài đặt khác"
         m \.row.between.middle.gap-3,
            m \div,
               "Làm dịu mắt"
            m Switch,
               checked: os.nightLight
               onchange: @onchangeNightLight
         m \.row.between.middle.gap-3,
            m \div,
               "Độ sáng màn hình"
            m Slider,
               fill: yes
               max: 1
               step: 0.1
               value: os.brightness
               onValueChange: @onValueChangeBrightness
