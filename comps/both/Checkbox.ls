Checkbox = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Checkbox,
         class: m.class do
            @attrs.class
         style: m.style do
            @attrs.style
         m \input.Checkbox-input,
            type: \checkbox
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Checkbox-check,
            "data-icon": \\uf00c
         if @children.length
            m \.Checkbox-text,
               @children
