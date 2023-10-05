App = m.comp do
   oninit: !->
      @text = "Nidoqueen"
      @bool = yes

      @menu =
         void
         ,,
         *  text: "Mở"
            color: \blue
         ,,
         *  text: "Ngôn ngữ hiển thị"
            icon: \fad:language
            subitems:
               *  text: "English"
               *  text: "Tiếng Việt"
               ,,
               *  text: "中国人"
               *  text: "日本語"
               ,,
               *  text: "ภาษาไทย"
               *  text: "Русский"
               *  text: "မြန်မာဘာသာစကား"
               *  text: "Մյանմարի լեզու"
               *  text: "भारतीय भाषा"
         *  text: "Chia sẻ"
            subitems:
               *  header: "Tiêu đề theo sau dấu phân cách"
               ,,
               *  text: "Mạng xã hội"
                  subitems:
                     *  text: "Facebook"
                        icon: \fab:facebook
                        color: \blue
                     *  text: "Tiktok"
                        icon: \fab:tiktok
                        label: "Douyin"
         ,,
         *  header: "Bị loại bỏ"
         ,,,
         *  beginGroup: \Test-edit
         *  header: "Chỉnh sửa 1"
         *  header: "Chỉnh sửa"
         *  text: "Sao chép"
            icon: \clone
            label: "Ctrl+C"
            group: \Test-copy
         *  text: "Xóa"
            icon: \trash
            label: "Delete"
            color: \red
         *  endGroup: \Test-edit
         *  text: "Sửa đổi"
            subitems:
               *  header: "Gán biến 'text'"
               *  text: "Ngẫu nhiên"
                  icon: \dice
                  click: !~>
                     @text = Math.random!
               *  text: "The quick brown fox jumps over the lazy dog (tạm dịch: Con cáo nâu nhanh nhẹn nhảy qua con chó lười biếng) là một pangram của tiếng Anh."
                  icon: \paragraph
                  label: "P"
                  click: (item) !~>
                     @text = item.text
         ,,
         *  text: "Ứng dụng"
            subitems:
               *  text: "Game"
                  icon: \gamepad
                  subitems:
                     *  text: "Giải đố"
                        subitems:
                           *  text: "2048"
                           *  text: "Monument Valley"
                              icon: \https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6QuXvNW_NvnUrwZKDiHXcg6Y-I2El5lOh5W1vT00&usqp=CAE&s
                     *  text: "Đua xe"
                        subitems:
                           *  text: "Angry Birds Go!"
                           *  text: "Asphalt 9: Legends"
                           *  text: "Hill Climb Racing"
                           *  text: "ZingSpeed Mobile"
                     *  text: "Hành động"
                        subitems:
                           *  text: "GTA"
                              icon: 871463
                              subitems:
                                 *  text: "Grand Theft Auto: San Andreas"
                                 *  text: "Grand Theft Auto IV"
                                 *  text: "Grand Theft Auto V"
                     *  text: "Kinh điển"
                        subitems:
                           *  header: "Tiêu đề trống 1"
                           *  header: "Tiêu đề trống 2"
               *  text: "Đồ họa"
                  subitems:
                     *  text: "Canva"
                     *  text: "Adobe Photoshop"
                     *  text: "Adobe Illustrator"
                     *  text: "Adobe Indesign"
                     *  text: "Adobe Premiere Pro"
                     *  text: "Sketchup"
                     *  text: "GIMP"
               ,,
               *  text: "Khác..."
         ,,,,
         *  text: "Thông tin thư mục"
            icon: \circle-info
            label: "Shift+Alt+I"
            click: (item) !~>
               console.log item
         ,,,

   view: ->
      m \.row.wrap.middle.gap-2.h-100.p-2.ov-auto,
         onscroll: os.fixBlurryScroll

         m \.col-12 "PasswordInput:"
         m PasswordInput,
            value: @text

         m \.col-12 "InputGroup:"
         m InputGroup,
            m Button,
               "A"
         m InputGroup,
            m Button,
               "A"
            m Button,
               color: \blue
               "B"
         m InputGroup,
            m Button,
               "A"
            m Button,
               color: \blue
               "B"
            m Button,
               "C"
         m InputGroup,
            m Button,
               color: \red
               "A"
            m TextInput
            m Button,
               "B"
            m Button,
               color: \blue
               "C"
            m Button,
               "D"
            m Button,
               color: \green
               "E"

         m \.col-12 "Menu:"
         m Menu
         m Menu,
            items: @menu
         m Menu,
            basic: yes
            items: @menu

         m \.col-12 "Icon:"
         m Icon,
            name: \swap
         m Icon,
            name: \far:globe
         m Icon,
            name: \fad:films
         m Icon,
            name: 1357643
         m Icon,
            name: \https://www.serebii.net/dungeon2/headshot/386.png

         m \.col-12 "Button:"
         [void \red \yellow \green \blue]map ~>
            m Button,
               color: it
               "Button"
         [void \red \yellow \green \blue]map ~>
            m Button,
               basic: yes
               color: it
               "Button"
         m Button,
            small: yes
            "Small"
         m Button,
            icon: \thumbs-up
            color: \blue
            "Like"
         m Button,
            icon: \thumbs-up
            small: yes
            "Like"
         m Button,
            width: 200
            "Width: 200"

         m \.col-12 "TextInput:"
         m TextInput
         m TextInput,
            icon: \quote-left
            value: @text
         m TextInput,
            rightIcon: \keyboard
            onchange: (event) !~>
               @text = "Nidoqueen"
         m TextInput,
            icon: 743977
            rightIcon: \https://www.serebii.net/dungeon2/headshot/031.png
            value: @text
            onchange: (event) !~>
               @text = event.target.value

         m \.col-12 "Image:"
         m \img.thumbnail,
            src: \https://www.serebii.net/dungeon2/headshot/448.png
         m \img.thumbnail,
            src: \https://i.ibb.co/gSDp1bR/i14745531949.jpg
