Menu = m.comp do
   oninit: !->
      @item = void
      @popper = void
      @timerId = void

   onbeforeupdate: !->
      @isSubmenu = @attrs.isSubmenu
      @root = @attrs.root or @
      if @isSubmenu
         items = @attrs.items
      else
         [items, clicks, groups] = os.formatMenuItems @attrs.items
      @items = items or []
      @clicks = clicks

   getIsActivedItem: (item) ->
      @item and @item.id == item.id

   setItem: (item) !->
      @item = item
      m.redraw!

   closePopper: !->
      if @popper
         popperEl = @popper.state.elements.popper
         m.mount popperEl
         popperEl.remove!
         @popper.destroy!
         @popper = void

   onmouseenterMenuItem: (item, event) !->
      unless @getIsActivedItem item
         targetEl = event.target
         if @isSubmenu
            @setItem void
            @closePopper!
            if item.subitems
               @timerId = setTimeout !~>
                  @setItem item
                  popperEl = document.createElement \div
                  popperEl.className = "OS-menuPopper"
                  targetEl.appendChild popperEl
                  comp =
                     view: ~>
                        m Menu,
                           isSubmenu: yes
                           root: @root
                           basic: yes
                           items: item.subitems
                  m.mount popperEl, comp
                  @popper = os.createPopper targetEl, popperEl,
                     placement: \right-start
                     offset: [-4 -2]
               , 200
         else
            @setItem void
            os.closeSubmenuMenu!
            if item.subitems
               @timerId = setTimeout !~>
                  @setItem item
                  rect = os.getRect targetEl
                  if clickedItem = await os.showSubmenuMenu rect, item.subitems, os.isFrme
                     @clicks[clickedItem.id]? clickedItem
                  @setItem void
               , 200

   onmouseleaveMenuItem: (item, event) !->
      clearTimeout @timerId

   onclickMenuItem: (item, event) !->
      unless item.subitems
         if @isSubmenu
            @root.attrs.onSubmenuItemClick? item
         else
            @clicks[item.id]? item

   onremove: !->
      if @isSubmenu
         @closePopper!
      else
         if @item
            os.closeSubmenuMenu!

   view: ->
      m \.Menu,
         class: m.class do
            "Menu--basic": @attrs.basic
            @attrs.class
         @items.map (item) ~>
            if item.divider
               m \.Menu-divider,
                  key: item.id
            else if item.isHeader
               m \.Menu-header,
                  key: item.id
                  item.header
            else
               m \.Menu-item,
                  key: item.id
                  class: m.class do
                     "active": @getIsActivedItem item
                     "Menu--#that" if item.color
                  onmouseenter: @onmouseenterMenuItem.bind void item
                  onmouseleave: @onmouseleaveMenuItem.bind void item
                  onclick: @onclickMenuItem.bind void item
                  m Icon,
                     class: "Menu-icon"
                     name: item.icon
                  m \.Menu-text,
                     item.text,
                  m \.Menu-label,
                     if item.subitems
                        m Icon,
                           name: \caret-right
                           compact: yes
                     else
                        item.label
