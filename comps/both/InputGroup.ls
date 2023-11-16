InputGroup = m.comp do
   view: ->
      m \.InputGroup,
         class: m.class do
            "disabled": @attrs.disabled
            "InputGroup--fill": @attrs.fill
            @attrs.class
         style: m.style do
            @attrs.style
         inert: @attrs.disabled
         @children
