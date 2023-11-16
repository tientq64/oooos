Radio = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Radio,
         class: m.class do
            "disabled": @attrs.disabled
            @attrs.class
         style: m.style do
            @attrs.style
         inert: @attrs.disabled
         m \input.Radio-input,
            type: \radio
            name: @attrs.name
            disabled: @attrs.disabled
            required: @attrs.required
            value: @attrs.value
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Radio-check,
            "data-icon": \\ue122
         if @children.length
            m \.Radio-text,
               @children
