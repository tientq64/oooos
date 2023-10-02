TextInput = m.comp do
   oninit: !->
      @input = void

   onchangeInput: (event) !->
      @attrs.onchange? event

   view: ->
      m \label.TextInput,
         class: m.class do
            "disabled": @attrs.disabled
            @attrs.class
         if @attrs.icon
            m Icon,
               class: "TextInput-icon TextInput-leftIcon"
               name: @attrs.icon
         @input =
            m \input.TextInput-input,
               name: @attrs.name
               type: @attrs.type
               disabled: @attrs.disabled
               min: @attrs.min
               max: @attrs.max
               step: @attrs.step
               minLength: @attrs.minLength
               maxLength: @attrs.maxLength
               pattern: @attrs.pattern
               required: @attrs.required
               "aria-autocomplete": \both
               placeholder: @attrs.placeholder
               value: @attrs.value
               oninput: @onchangeInput
         if @attrs.rightIcon
            m Icon,
               class: "TextInput-icon TextInput-rightIcon"
               name: @attrs.rightIcon
