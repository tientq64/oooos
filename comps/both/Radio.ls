Radio = m.comp do
   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.Radio,
         class: m.class do
            @attrs.class
         style: m.style do
            @attrs.style
         m \input.Radio-input,
            type: \radio
            checked: @attrs.checked
            onchange: @onchangeInput
         m \.Radio-check,
            "data-icon": \\ue122
         if @children.length
            m \.Radio-text,
               @children
