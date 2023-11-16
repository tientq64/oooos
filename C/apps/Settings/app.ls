App = m.comp do
   oninit: !->
      $ := @
      @routeItems =
         *  text: "Trang chính"
            icon: \home
            value: \/home
         *  text: "Màn hình và hiển thị"
            icon: \display
            value: \/display
         *  text: "Giao diện"
            icon: \palette
            value: \/theme
         *  text: "Phông chữ"
            icon: \font
            value: \/text
         *  text: "Tác vụ"
            icon: \window-restore
            value: \/tasks
         *  text: "Thông báo"
            icon: \bell
            value: \/notify
         *  text: "Âm thanh"
            icon: \volume
            value: \/audio
         *  text: "Pin và hiệu suất"
            icon: \battery
            value: \/power
         *  text: "Mạng và kết nối"
            icon: \wifi
            value: \/network
         *  text: "Tệp và bộ nhớ"
            icon: \hard-drive
            value: \/storage
         *  text: "Taskbar"
            icon: \chalkboard
            value: \/taskbar
         *  text: "Màn hình khóa"
            icon: \tv
            value: \/lockScreen
         *  text: "Tài khoản"
            icon: \user
            value: \/account
         *  text: "Ứng dụng"
            icon: \grid-2
            value: \/apps
         *  text: "Thời gian và ngôn ngữ"
            icon: \clock
            value: \/time
         *  text: "Bàn phím và nhập"
            icon: \keyboard
            value: \/keyboard
         *  text: "Công cụ nhà phát triển"
            icon: \code
            value: \/developer
         *  text: "Quyền và bảo mật"
            icon: \shield-halved
            value: \/security
         *  text: "Cập nhật"
            icon: \arrows-rotate
            value: \/update

   oncreate: !->
      @router = os.createRouter @routerVnode.dom,
         "/home": HomePage
         "/display": DisplayPage
         "/theme": ThemePage
         "/text": FontPage
         "/tasks": TasksPage
         "/notify": NotifyPage
         "/audio": AudioPage
         "/power": PowerPage
         "/network": NetworkPage
         "/storage": StoragePage
         "/taskbar": TaskbarPage
         "/lockScreen": LockScreenPage
         "/account": AccountPage
         "/apps": AppsPage
         "/time": TimePage
         "/keyboard": KeyboardPage
         "/developer": DeveloperPage
         "/security": SecurityPage
         "/update": UpdatePage
      @router.set \/home

   onItemClickRoute: (item) !->
      @router.set item.value

   view: ->
      m \.row.gap-6.h-100p.p-3,
         m \.col-0.ov-auto,
            style: m.style do
               width: 280
            if @router
               m Menu,
                  activeItemClass: "bg-blue2 text-white"
                  fill: yes
                  basic: yes
                  compact: yes
                  value: @router?route?pattern
                  onItemClick: @onItemClickRoute
                  items: @routeItems
         @routerVnode =
            m \.col.ov-auto

HomePage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "HomePage"

DisplayPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "DisplayPage"

ThemePage = m.comp do
   oninit: !->
      @colors =
         *  text: "Xám"
            value: \#1e293b
         *  text: "Đỏ"
            value: \#9f1239
         *  text: "Cam"
            value: \#9a3412
         *  text: "Vàng"
            value: \#854d0e
         *  text: "Lục"
            value: \#166534
         *  text: "Xanh lơ"
            value: \#155e75
         *  text: "Lam"
            value: \#1e40af
         *  text: "Chàm"
            value: \#3730a3
         *  text: "Tím"
            value: \#6b21a8
         *  text: "Hồng"
            value: \#9d174d
      os.requestPerm \desktopBgView

   onValueChangeDesktopBgImageFit: (val) !->
      os.setDesktopBgImageFit val

   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "Hình nền"
            m \.col-0,
               m \img.image-thumbnail.image-contrast,
                  src: os.desktopBgImageDataUrl
                  height: 120
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "Màu nền"
            m \.row.gap-1,
               @colors.map (color) ~>
                  m \.col-0.row.center.middle.w-30px.h-30px.rounded,
                     style: m.style do
                        background: color.value
                     tooltip: "#{color.text}|top"
         m \.row.between.middle.py-2,
            m \.row.middle.h-30px,
               "Kéo giãn hình nền"
            m Select,
               value: os.desktopBgImageFit
               items: os.desktopBgImageFits
               onValueChange: @onValueChangeDesktopBgImageFit

FontPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "FontPage"

TasksPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "TasksPage"

NotifyPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "NotifyPage"

AudioPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "AudioPage"

PowerPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "Chế độ tiết kiệm pin"
            m Switch

NetworkPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "NetworkPage"

StoragePage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "StoragePage"

TaskbarPage = m.comp do
   oninit: !->
      os.requestPerm \taskbarView

   onValueChangeTaskbarPosition: (val) !->
      os.setTaskbarPosition val

   onchangeTaskbarPositionLocked: (event) !->
      os.setTaskbarPositionLocked event.target.checked

   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            class: m.class do
               "disabled": os.taskbarPositionLocked
            m \.row.middle.h-30px,
               "Vị trí taskbar"
            m Select,
               disabled: os.taskbarPositionLocked
               value: os.taskbarPosition
               items: os.taskbarPositions
               onValueChange: @onValueChangeTaskbarPosition
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "Khóa vị trí taskbar"
            m Switch,
               checked: os.taskbarPositionLocked
               onchange: @onchangeTaskbarPositionLocked

LockScreenPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "LockScreenPage"

AccountPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "AccountPage"

AppsPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "AppsPage"

TimePage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "Định dạng ngày giờ"

KeyboardPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "KeyboardPage"

DeveloperPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "DeveloperPage"

SecurityPage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "SecurityPage"

UpdatePage = m.comp do
   view: ->
      m \.column.h-100p.divide-y.divide-gray3,
         m \.row.between.py-2,
            m \.row.middle.h-30px,
               "UpdatePage"
