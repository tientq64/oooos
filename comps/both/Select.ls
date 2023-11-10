Select = m.comp do
   oninit: !->
      @controlled = \value of @attrs
      @isShowPopper = no

   onbeforeupdate: (old) !->
      [@items, @clicks, @groups, @allItems] = os.formatMenuItems @attrs.items
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
         active: @isShowPopper
         disabled: @attrs.disabled
         icon: @item?icon ? (@hasSomeIconAllItems and \blank or void)
         rightIcon: \sort
         tooltip: @attrs.tooltip
         onclick: @onclick
         oncontextmenu: @attrs.oncontextmenu
         @item?text
