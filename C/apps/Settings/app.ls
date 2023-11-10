App = m.comp do
   oninit: !->
      $ := @
      @routeItems =
         *  text: "Trang chính"
            icon: \home
            value: \/home
         *  text: "Màn hình"
            icon: \display
            value: \/display
         *  text: "Chủ đề và màu sắc"
            icon: \palette
            value: \/theme
         *  text: "Phông chữ"
            icon: \font
            value: \/text
         *  text: "Hình nền và desktop"
            icon: \image-landscape
            value: \/desktop
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
         *  text: "Bộ nhớ lưu trữ"
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
         *  text: "Ngày và giờ"
            icon: \clock
            value: \/time
         *  text: "Ngôn ngữ"
            icon: \language
            value: \/language
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
         "/text": TextPage
         "/desktop": DesktopPage
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
         "/language": LanguagePage
         "/keyboard": KeyboardPage
         "/developer": DeveloperPage
         "/security": SecurityPage
         "/update": UpdatePage
      @router.set \/home

   onItemClickRoute: (item) !->
      @router.set item.value

   view: ->
      m \.row.gap-5.h-100.p-3,
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
      m \.column.h-100,
         "HomePage"

DisplayPage = m.comp do
   view: ->
      m \.column.h-100,
         "DisplayPage"

ThemePage = m.comp do
   view: ->
      m \.column.h-100,
         "ThemePage"

TextPage = m.comp do
   view: ->
      m \.column.h-100,
         "TextPage"

DesktopPage = m.comp do
   view: ->
      m \.column.h-100,
         "DesktopPage"

NotifyPage = m.comp do
   view: ->
      m \.column.h-100,
         "NotifyPage"

AudioPage = m.comp do
   view: ->
      m \.column.h-100,
         "AudioPage"

PowerPage = m.comp do
   view: ->
      m \.column.h-100,
         "PowerPage"

NetworkPage = m.comp do
   view: ->
      m \.column.h-100,
         "NetworkPage"

StoragePage = m.comp do
   view: ->
      m \.column.h-100,
         "StoragePage"

TaskbarPage = m.comp do
   view: ->
      m \.column.h-100,
         "TaskbarPage"

LockScreenPage = m.comp do
   view: ->
      m \.column.h-100,
         "LockScreenPage"

AccountPage = m.comp do
   view: ->
      m \.column.h-100,
         "AccountPage"

AppsPage = m.comp do
   view: ->
      m \.column.h-100,
         "AppsPage"

TimePage = m.comp do
   view: ->
      m \.column.h-100,
         "TimePage"

LanguagePage = m.comp do
   view: ->
      m \.column.h-100,
         "LanguagePage"

KeyboardPage = m.comp do
   view: ->
      m \.column.h-100,
         "KeyboardPage"

DeveloperPage = m.comp do
   view: ->
      m \.column.h-100,
         "DeveloperPage"

SecurityPage = m.comp do
   view: ->
      m \.column.h-100,
         "SecurityPage"

UpdatePage = m.comp do
   view: ->
      m \.column.h-100,
         "UpdatePage"


TaskbarPage = m.comp do
   view: ->
      m \.column.h-100,
         "TaskbarPage"
