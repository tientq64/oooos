Button = m.comp do
   onbeforeupdate: !->
      @attrs.type ?= \button

   view: ->
      m \button.Button,
         class: m.class do
            "active": @attrs.active
            "disabled": @attrs.disabled
            "Button--fill": @attrs.fill
            "Button--basic": @attrs.basic
            "Button--bordered": !@attrs.basic
            "Button--small": @attrs.small
            "Button--#that Button--hasColor" if @attrs.color
            @attrs.class
         style: m.style do
            width: @attrs.width
            height: @attrs.height
            minHeight: @attrs.height
            @attrs.style
         type: @attrs.type
         disabled: @attrs.disabled
         tooltip: @attrs.tooltip
         onclick: @attrs.onclick
         oncontextmenu: @attrs.oncontextmenu
         if @attrs.icon?
            m Icon,
               class: "Button-icon Button-leftIcon"
               name: @attrs.icon
         if @children.length
            m \.Button-text,
               @children
         if @attrs.rightIcon?
            m Icon,
               class: "Button-icon Button-rightIcon"
               name: @attrs.rightIcon
