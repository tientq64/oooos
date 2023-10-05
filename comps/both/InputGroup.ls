InputGroup = m.comp do
   view: ->
      m \.InputGroup,
         class: m.class do
            "InputGroup--fill": @attrs.fill
            @attrs.class
         style: m.style do
            @attrs.style
         @children
