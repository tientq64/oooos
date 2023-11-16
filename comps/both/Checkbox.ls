Checkbox = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Checkbox,
         class: m.class do
            "disabled": @attrs.disabled
            @attrs.class
         style: m.style do
            @attrs.style
         inert: @attrs.disabled
         m \input.Checkbox-input,
            type: \checkbox
            name: @attrs.name
            disabled: @attrs.disabled
            required: @attrs.required
            value: @attrs.value
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Checkbox-check,
            "data-icon": \\uf00c
         if @children.length
            m \.Checkbox-text,
               @children
