Select = m.comp do
   oninit: !->
      @controlled = \value of @attrs
      @isShowPopper = no

   onbeforeupdate: (old) !->
      @attrs.rightIcon ?= \sort
      [@items,,, @allItems] = os.formatMenuItems @attrs.items
      @items ?= []
      @hasSomeIconAllItems = @allItems.some (.icon?)
      if @controlled
         @value = @attrs.value
         @item = @allItems.find (.value == @value)
      else if !old
         @value = @attrs.defaultValue
         @item = @allItems.find (.value == @value)

   onclick: (event) !->
      os.safeSyncCall @attrs.onclick, event
      if !@isShowPopper and @items.length
         @isShowPopper = yes
         rect = @dom.getBoundingClientRect!
         clickedItem = await os.showSelectMenu rect, @items, @value, os.isFrme
         if clickedItem
            unless @controlled
               @value = clickedItem.value
               @item = @allItems.find (.value == @value)
            os.safeSyncCall @attrs.onValueChange, clickedItem.value
         @isShowPopper = no
         m.redraw!

   onremove: !->
      if @isShowPopper
         os.closeSelectMenu!

   view: ->
      m Button,
         class:
            "Select"
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
         icon: @item?icon ? (@hasSomeIconAllItems and \blank or void)
         rightIcon: @attrs.rightIcon
         tooltip: @attrs.tooltip
         onclick: @onclick
         oncontextmenu: @attrs.oncontextmenu
         if @children.length
            that
         else
            @item?text
