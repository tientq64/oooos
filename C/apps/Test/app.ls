App = m.comp do
   oninit: !->
      @text = "Nidorina"
      @bool = yes

      @menu =
         *  text: "Mở"
         yes
         *  text: "Xóa"
            icon: \trash
            color: \red

   view: ->
      m \.row.wrap.middle.gap-2.p-2,
         m \.col-12 "Menu:"
         m Menu
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
            name: 10167140
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
            icon: \quote-left
            rightIcon: \keyboard
            value: @text
            onchange: (event) !~>
               @text = event.target.value

         m \.col-12 "Image:"
         m \img.thumbnail,
            src: \https://www.serebii.net/dungeon2/headshot/448.png
         m \img.thumbnail,
            src: \https://i.ibb.co/gSDp1bR/i14745531949.jpg
