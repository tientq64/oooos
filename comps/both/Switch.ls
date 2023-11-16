Switch = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Switch,
         class: m.class do
            "disabled": @attrs.disabled
            @attrs.class
         style: m.style do
            @attrs.style
         inert: @attrs.disabled
         m \input.Switch-input,
            type: \checkbox
            name: @attrs.name
            disabled: @attrs.disabled
            required: @attrs.required
            value: @attrs.value
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Switch-track,
            m \.Switch-thumb
         if @children.length
            m \.Switch-text,
               @children
