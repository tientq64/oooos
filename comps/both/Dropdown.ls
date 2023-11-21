Dropdown = m.comp do
   oninit: !->
      @isShowPopper = no

   onbeforeupdate: !->
      @attrs.placement ?= \bottom
      @attrs.flips ?= [\top]
      [@items, @clicks,, @allItems] = os.formatMenuItems @attrs.items
      @items ?= []

   onclick: (event) !->
      os.safeSyncCall @attrs.onclick, event
      if !@isShowPopper and @items.length
         @isShowPopper = yes
         rect = @dom.getBoundingClientRect!
         clickedItem = await os.showDropdownMenu rect, @items, @attrs.placement, @attrs.flips, os.isFrme
         if clickedItem
            os.safeSyncCall @clicks[clickedItem.id], clickedItem
            os.safeSyncCall @attrs.onItemClick, clickedItem
         @isShowPopper = no
         m.redraw!

   onremove: !->
      if @isShowPopper
         os.closeDropdownMenu!

   view: ->
      m Button,
         class:
            "Dropdown"
            @attrs.class
         style:
            @attrs.style
         width: @attrs.width
         height: @attrs.height
         fill: @attrs.fill
         basic: @attrs.basic
         small: @attrs.small
         active: @isShowPopper
         disabled: @attrs.disabled
         icon: @attrs.icon
         rightIcon: @attrs.rightIcon
         tooltip: @attrs.tooltip
         onclick: @onclick
         oncontextmenu: @attrs.oncontextmenu
         @children
