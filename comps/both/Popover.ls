Popover = m.comp do
   oninit: !->
      @controlled = \isOpen of @attrs
      @isOpen = void
      @popper = void
      @attrs.interactionKind ?= \click

   oncreate: !->
      if @dom instanceof Element
         switch @attrs.interactionKind
         | \click
            @dom.addEventListener \click @onclickTarget
         | \contextmenu
            @dom.addEventListener \contextmenu @onclickTarget

   onbeforeupdate: (old) !->
      if @controlled
         @isOpen = Boolean @attrs.isOpen
      else if !old
         @isOpen = Boolean @attrs.defaultIsOpen
      if typeof! @children.0 == \Object
         @children.0{}attrs.onremove = @closePopper

   onupdate: (old) !->
      if @controlled or !old
         @updateIsOpen!
      if @popper
         @popper.update!

   onclickTarget: (event) !->
      if @controlled
         os.safeSyncCall @onInteraction, !@isOpen
      else
         != @isOpen
         @updateIsOpen!
      m.redraw!

   updateIsOpen: !->
      if @isOpen
         unless @popper
            [content, isErr] = os.safeSyncCastVal @attrs.content, @closeContent
            if content? and !isErr and @dom instanceof Element
               popperEl = document.createElement \div
               popperEl.className = "Popover-popper Portal"
               portalEl = @dom.closest \.Portal
               portalEl.appendChild popperEl
               m.mount popperEl,
                  view: ~>
                     m \.Popover-content,
                        content
               @popper = os.createPopper @dom, popperEl,
                  placement: @attrs.placement
                  flips: @attrs.flips
                  padding: 4
               @dom.classList.add \active
               document.addEventListener \mousedown @onmousedownGlobal
               m.redraw!
      else
         @closePopper!

   closeContent: !->
      unless @controlled
         @closePopper!

   closePopper: !->
      if @popper
         @isOpen = no
         popperEl = @popper.state.elements.popper
         m.mount popperEl
         popperEl.remove!
         @popper.destroy!
         @popper = void
         @dom?classList.remove \active
         document.removeEventListener \mousedown @onmousedownGlobal
         m.redraw!

   onmousedownGlobal: (event) !->
      popperEl = @popper.state.elements.popper
      unless popperEl.contains event.target
         if @controlled
            os.safeSyncCall @onInteraction, no
         else
            @closePopper!

   view: ->
      @children.0
