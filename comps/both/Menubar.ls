Menubar = m.comp do
   oninit: !->
      @menu = void

   onbeforeupdate: !->
      @menus = os.formatMenus @attrs.menus

   onclickMenu: (menu, event) !->
      @menu = void
      [items, clicks, groups] = os.formatMenuItems menu.subitems
      if items
         @menu = menu
         m.redraw!
         rect = event.target.getBoundingClientRect!
         clickedItem = await os.showMenubarMenu rect, items, os.isFrme
         if clickedItem
            os.safeSyncCall clicks[clickedItem.id], clickedItem
         @menu = void
      m.redraw!

   onremove: !->
      if @menu
         os.closeMenubarMenu!
         @menu = void

   view: ->
      m \.Menubar,
         @menus.map (menu) ~>
            m Button,
               key: menu.id
               active: @menu?id == menu.id
               basic: yes
               small: yes
               icon: menu.icon
               onclick: @onclickMenu.bind void menu
               menu.text
