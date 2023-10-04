Menu = m.comp do
   oninit: !->
      @item = void
      @popper = void
      @timerId = void

   onbeforeupdate: !->
      @level = @attrs.level ? 0
      if @level == 0
         [items, clicks] = os.formatMenuItems @attrs.items
      else
         items = @attrs.items
      @items = items or []
      @clicks = clicks

   getIsActive: (item) ->
      @item and @item.id == item.id

   setItem: (item) !->
      @item = item
      m.redraw!

   closePopper: !->
      if @popper
         @popper.state.elements.popper.remove!
         @popper.destroy!
         @popper = void

   onmouseenterMenuItem: (item, event) !->
      unless @getIsActive item
         targetEl = event.target
         if @level == 0
            @setItem void
            os.closeSubmenu!
            if item.subitems
               @timerId = setTimeout !~>
                  @setItem item
                  rect = os.getRect targetEl
                  if clickedItem = await os.showSubmenu rect, item.subitems
                     @clicks[clickedItem.id]? clickedItem
                  @setItem void
               , 200
         else
            @setItem void
            @closePopper!
            if item.subitems
               @timerId = setTimeout !~>
                  @setItem item
                  comp =
                     view: ->
                        m Menu,
                           level: @level + 1
                           items: item.subitems
                  popperEl = document.createElement \div
                  popperEl.className = "Menu-submenu"
                  targetEl.appendChild popperEl
                  m.mount popperEl, comp
                  @popper = os.createPopper targetEl, popperEl,
                     placement: \right-start
                     offset: [-4 -2]
               , 200

   onmouseleaveMenuItem: (item, event) !->
      clearTimeout @timerId

   onclickMenuItem: (item, event) !->
      unless item.subitems
         if @level == 0
            @clicks[item.id]? item
         else
            os.closeSubmenu item

   view: ->
      m \.Menu,
         class: m.class do
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
                     "active": @getIsActive item
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
