Switch = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Switch,
         class: m.class do
            @attrs.class
         style: m.style do
            @attrs.style
         m \input.Switch-input,
            type: \checkbox
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Switch-track,
            m \.Switch-thumb
         if @children.length
            m \.Switch-text,
               @children
