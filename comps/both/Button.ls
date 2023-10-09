Button = m.comp do
   onbeforeupdate: !->
      @attrs.type ?= \button

   view: ->
      m \button.Button,
         class: m.class do
            "disabled": @attrs.disabled
            "Button--basic": @attrs.basic
            "Button--bordered": !@attrs.basic
            "Button--small": @attrs.small
            "Button--#that Button--hasColor" if @attrs.color
            @attrs.class
         style: m.style do
            width: @attrs.width
            @attrs.style
         type: @attrs.type
         disabled: @attrs.disabled
         onclick: @attrs.onclick
         if @attrs.icon
            m Icon,
               name: @attrs.icon
         if @children.length
            m \.Button-text,
               @children
         if @attrs.rightIcon
            m Icon,
               name: @attrs.rightIcon
