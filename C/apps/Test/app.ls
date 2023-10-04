App = m.comp do
   oninit: !->
      @text = "Nidoqueen"
      @bool = yes

      @menu =
         yes
         yes
         *  text: "Mở"
            color: \blue
         yes
         *  text: "Ngôn ngữ hiển thị"
            icon: \fad:language
            subitems:
               *  text: "English"
               *  text: "Tiếng Việt"
               yes
               *  text: "中国人"
               *  text: "日本語"
               yes
               *  text: "ภาษาไทย"
               *  text: "Русский"
               *  text: "မြန်မာဘာသာစကား"
               *  text: "Մյանմարի լեզու"
               *  text: "भारतीय भाषा"
         *  text: "Chia sẻ"
            subitems:
               yes
               yes
               *  header: "Tiêu đề theo sau dấu phân cách"
               yes
               *  text: "Mạng xã hội"
                  subitems:
                     *  text: "Facebook"
                        icon: \fab:facebook
                        color: \blue
                     *  text: "Tiktok"
                        icon: \fab:tiktok
                        label: "Douyin"
         yes
         *  header: "Bị loại bỏ"
         yes
         yes
         *  header: "Chỉnh sửa 1"
         *  header: "Chỉnh sửa"
         *  text: "Sao chép"
            icon: \clone
            label: "Ctrl+C"
         *  text: "Xóa"
            icon: \trash
            label: "Delete"
            color: \red
         *  text: "Sửa đổi"
            subitems:
               *  header: "Đặt biến 'text'"
               *  text: "Ngẫu nhiên"
                  icon: \dice
                  click: !~>
                     @text = Math.random!
               *  text: "The quick brown fox jumps over the lazy dog (tạm dịch: Con cáo nâu nhanh nhẹn nhảy qua con chó lười biếng) là một pangram của tiếng Anh."
                  icon: \paragraph
                  label: "P"
                  click: (item) !~>
                     @text = item.text
         yes
         *  text: "Ứng dụng"
            subitems:
               *  text: "Game"
                  icon: \gamepad
                  subitems:
                     *  text: "Hành động"
                        subitems:
                           *  text: "GTA 5"
                              icon: 871463
                     *  text: "Đua xe"
                        subitems:
                           *  text: "Angry Birds Go!"
                           *  text: "Asphalt 9: Legends"
                           *  text: "Hill Climb Racing"
                     *  text: "Giải đố"
                        subitems:
                           *  text: "1024"
                           *  text: "Monument Valley"
                              icon: \https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR6QuXvNW_NvnUrwZKDiHXcg6Y-I2El5lOh5W1vT00&usqp=CAE&s
                     *  text: "Kinh điển"
                        subitems:
                           yes
                           yes
               *  text: "Đồ họa"
                  subitems:
                     *  text: "Canva"
                     *  text: "Adobe Photoshop"
                     *  text: "Adobe Illustrator"
                     *  text: "Adobe Indesign"
                     *  text: "Adobe Premiere Pro"
                     *  text: "Sketchup"
                     *  text: "GIMP"
               yes
               *  text: "Khác..."
         yes
         yes
         yes
         *  text: "Thông tin thư mục"
            icon: \circle-info
            label: "Shift+Alt+I"
         yes
         yes

   view: ->
      m \.row.wrap.middle.gap-2.h-100.p-2.ov-auto,
         onscroll: os.fixBlurryScroll

         m \.col-12 "Menu:"
         m Menu
         m Menu,
            items: @menu
         m Menu,
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
