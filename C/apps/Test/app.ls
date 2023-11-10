App = m.comp do
   oninit: !->
      @text = "Nidoqueen"
      @bool = yes
      @boolTestPatchDom = no
      @popoverIsOpen = yes
      @longText = "The quick brown fox jumps over the lazy dog (tạm dịch: Con cáo nâu nhanh nhẹn nhảy qua con chó lười biếng) là một pangram của tiếng Anh."

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
               *  header: "Tiêu đề theo sau dấu phân cách rồi đến header"
               ,,
               *  header: ""
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
               *  text: @longText
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
                                    subitems:
                                       *  text: "Chapters"
                                          subitems:
                                             *  text: "Chapter 1: North Yankton, 9 years ago"
                                             *  text: "Chapter 2: Franklin and Lamar repossess two convertibles for an Armenian car dealer, Simeon"
                                             *  text: "Chapter 3: Franklin and Lamar go to a shady part of Vespucci Beach to repo a bike for Simeon"
                                             *  text: "Chapter 4: Franklin heads to Rockford Hills to repo a car for Simeon"
                                             *  text: "Chapter 5: Jimmy gets in trouble with some gangsters and calls Michael for help"
                                             ,,
                                             *  text: "More..."
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

      @pokemons =
         *  no: 554
            text: "Darumaka (Dạng Galar)"
            types: [\ice]
            dex: "Sống quá lâu ở vùng tuyết phủ, túi lửa của nó đã nguội lạnh và thoái hóa. Hiện tại nó đã có bộ phận tạo ra khí lạnh."
         *  no: 459
            text: "Snover"
            types: [\grass \ice]
            dex: "Snover sống sâu trong núi tuyết. Nó chôn chân xuống tuyết để hấp thụ nước và khí lạnh."
         *  no: 60
            text: "Poliwag"
            types: [\water]
            dex: "Poliwag rất thích lên cạn bất chấp mọi nguy hiểm. Tuy chỉ lê bước lạch bạch, chúng có thể lao nhanh xuống nước nếu gặp phải kẻ thù."
         *  no: 861
            text: "Grimmsnarl"
            types: [\dark \fairy]
            dex: "Nó cuộn toàn bộ lông trên cơ thể lại để tăng sức mạnh cơ bắp, Grimmsnarl có sức mạnh vượt trội hơn cả Machamp."
         *  no: 862
            text: "Obstagoon"
            types: [\dark \normal]
            dex: "Sở hữu giọng nói với âm lượng khủng khiếp. Tiếng hét để đe dọa của nó còn được gọi là chiêu thức Chặn Đứng."
         *  no: 178
            text: "Xatu"
            types: [\psychic \flying]
            dex: "Nó có thể nhìn thấu quá khứ và tương lai. Là loại Pokémon kì lạ, nó quan sát chuyển động của mặt trời mỗi ngày."
         *  no: 817
            text: "Drizzile"
            types: [\water]
            dex: "Là một chiến binh tài giỏi, Pokémon này chiến đấu bằng cách tạo ra những quả bóng nước từ hơi ẩm trong lòng bàn tay."
         *  no: 328
            text: "Trapinch"
            types: [\ground]
            dex: "Tổ mà nó tạo ra trên sa mạc có hình dạng cong như cái chén, nếu rơi vào thì không thể thoát ra."

      @selectItems =
         *  text: "String"
            value: \van-ban
         *  text: "Number"
            icon: \hashtag
            value: 16
         *  text: "Boolean"
            value: no
         *  text: "NaN"
            value: NaN
         *  text: "Null"
            value: null
         *  text: "Undefined"
            value: void
         *  text: "Icon"
            icon: \fire
            value: \fire
         *  text: "Only text"
         *  value: "Only value"
         *  text: "Submenu"
            subitems:
               *  text: \1
                  icon: 0
                  value: 1
               *  text: \2
                  icon: \o
                  value: 2
      @selectValue = 16

   oncreate: !->

   view: ->
      m \.row.wrap.middle.gap-3.h-100.p-3.ov-auto,
         onscroll: os.fixBlurryScroll

         m Switch,
            checked: os.darkMode
            onchange: !~>
               os.setDarkMode event.target.checked
            "Light/dark mode"
         m Switch,
            checked: @boolTestPatchDom
            onchange: !~>
               @boolTestPatchDom = event.target.checked
            "@boolTestPatchDom"
         m Button,
            onclick: !~>
               setTimeout !~>
                  != @boolTestPatchDom
                  m.redraw!
               , 2000
            "Sau 2s"
         if @boolTestPatchDom
            m \div,
               "Đoạn này xuất hiện với mục đích test bản vá DOM."
         m \span,
            "@bool: #@bool"

         m \h3.col-12 "Select:"
         m Select
         m Select,
            value: @selectValue
            items: @selectItems
            onValueChange: (@selectValue) !~>

         m \h3.col-12 "Radio:"
         m Radio
         m Radio,
            checked: @bool
            onchange: (event) !~>
               @bool = event.target.checked
            "Radio"

         m \h3.col-12 "Checkbox:"
         m Checkbox
         m Checkbox,
            checked: @bool
            onchange: (event) !~>
               @bool = event.target.checked
            "Checkbox"

         m \h3.col-12 "Textarea:"
         m Textarea
         m Textarea,
            resize: \vertical
            value: @text
            onchange: (event) !~>
               @text = event.target.value

         m \h3.col-12 "Tooltip:"
         m Button,
            tooltip: "Chào ông cháu 🤭"
            "Hover me"
         m \span,
            tooltip: "Tooltip của <span>"
            "Span"
         m Button,
            tooltip: "Tooltip này nên hiển thị ở bên trái nếu có thể|left,"
            "Với vị trí"
         m Button,
            tooltip: "Tooltip này nên hiển thị ở các vị trí trái, trên, dưới, theo thứ tự nếu có thể|left,top,bottom"
            "Nhiều vị trí"
         m Button,
            tooltip: "Không hợp lệ nên hiển thị|riGht,"
            "Vị trí không hợp lệ"
         m \span,
            tooltip: "Tooltip|top|"
            "Thêm dấu | ở cuối để đảm bảo tooltip hiển thị đúng \"|top\""
         m Button,
            tooltip: ""
            "Trống"
         m Button,
            tooltip: "   "
            "Blank"
         m Button,
            tooltip: @longText
            "Dài"
         m \.col-12
         m Button,
            width: 80
            height: 80
            tooltip: "Quá to"
            "To"

         m \h3.col-12 "Popover:"
         m Popover,
            content: ~>
               "Đây là Popover content."
            m \p,
               "<p> tag"
         m Popover,
            content: (close) ~>
               m \.p-3,
                  m \p,
                     "Nhấn nút phía dưới để mở Popover con:"
                  m Popover,
                     content: (close2) ~>
                        m Menu,
                           basic: yes
                           items: @menu
                           onItemClick: (item) !~>
                              close!
                     m Button,
                        "Button 2"
            m Button,
               "Button"
         m Popover,
            m TextInput
         m Popover
         m Button,
            onclick: !~>
               != @popoverIsOpen
            "@popoverIsOpen: #@popoverIsOpen"
         m Popover,
            maxWidth: 400
            isOpen: @popoverIsOpen
            content: ~>
               m \.m-3,
                  @longText
            m Button,
               "Controlled"

         m \h3.col-12 "Table:"
         m Table,
            striped: yes
            m \tbody,
               @pokemons.map (pokemon, i) ~>
                  m \tr,
                     m \td i
                     m \td pokemon.text
                     m \td pokemon.types.join " / "
         m Table,
            fill: yes
            m \thead,
               m \tr,
                  m \th "#"
                  m \th "Text"
                  m \th "Types"
            m \tbody,
               @pokemons.map (pokemon, i) ~>
                  m \tr,
                     m \td i
                     m \td pokemon.text
                     m \td pokemon.types.join " / "
         m Table,
            style:
               height: 200
            striped: yes
            truncate: yes
            interactive: yes
            m \thead,
               m \tr,
                  m \th "#"
                  m \th "Text"
                  m \th "Types"
                  m \th "Dex"
            m \tbody,
               @pokemons.map (pokemon, i) ~>
                  m \tr,
                     m \td i
                     m \td pokemon.text
                     m \td pokemon.types.join " / "
                     m \td.text-wrap pokemon.dex

         m \h3.col-12 "PasswordInput:"
         m PasswordInput
         m PasswordInput,
            icon: \lock
            value: @text

         m \h3.col-12 "InputGroup:"
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
               color: \yellow
               "D"

         m \h3.col-12 "Menu:"
         m Menu
         m Menu,
            items: @menu
         m Menu,
            basic: yes
            items: @menu

         m \h3.col-12 "Icon:"
         m Icon,
            name: \swap
         m Icon,
            name: \far:globe
         m Icon,
            name: \fad:films
         m Icon,
            name: 1357643
         m Icon
         m Icon,
            name: \https://www.serebii.net/dungeon2/headshot/386.png

         m \h3.col-12 "Button:"
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

         m \h3.col-12 "TextInput:"
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

         m \h3.col-12 "Image:"
         m \img,
            src: \https://i.ibb.co/gSDp1bR/i14745531949.jpg
         m \img.thumbnail,
            src: \https://www.serebii.net/dungeon2/headshot/448.png
