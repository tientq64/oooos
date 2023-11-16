TextInput = m.comp do
   oninit: !->
      @input = void

   oncreate: !->
      if @attrs.autoFocus
         @input.dom.focus!

   oninputInput: (event) !->
      @attrs.onchange? event

   oncontextmenuInput: (event) !->
      os.addContextMenu event,
         *  beginGroup: \TextInput
         *  text: "Hoàn tác"
            icon: \arrow-rotate-left
            click: !~>
               @input.dom.focus!
               document.execCommand \undo
         *  text: "Làm lại"
            icon: \arrow-rotate-right
            click: !~>
               @input.dom.focus!
               document.execCommand \redo
         ,,
         *  text: "Cắt"
            icon: \scissors
            click: !~>
               @input.dom.focus!
               document.execCommand \cut
         *  text: "Sao chép"
            icon: \copy
            click: !~>
               @input.dom.focus!
               document.execCommand \copy
         *  text: "Dán"
            icon: \paste
            click: !~>
               @input.dom.focus!
               text = await navigator.clipboard.readText!
               document.execCommand \insertText,, text
         ,,
         *  text: "Chọn tất cả"
            click: !~>
               @input.dom.focus!
               document.execCommand \selectAll
      @attrs.oncontextmenu? event

   view: ->
      m \label.TextInput,
         class: m.class do
            "disabled": @attrs.disabled
            "TextInput--fill": @attrs.fill
            @attrs.class
         style: m.style do
            @attrs.style
         inert: @attrs.disabled
         tooltip: @attrs.tooltip
         if @attrs.icon?
            m Icon,
               class: "TextInput-icon TextInput-leftIcon"
               name: @attrs.icon
         @input =
            m \input.TextInput-input,
               name: @attrs.name
               type: @attrs.type
               min: @attrs.min
               max: @attrs.max
               step: @attrs.step
               minLength: @attrs.minLength
               maxLength: @attrs.maxLength
               pattern: @attrs.pattern
               required: @attrs.required
               disabled: @attrs.disabled
               "aria-autocomplete": \both
               placeholder: @attrs.placeholder
               value: @attrs.value
               oninput: @oninputInput
               oncontextmenu: @oncontextmenuInput
         if @attrs.rightIcon?
            m Icon,
               class: "TextInput-icon TextInput-rightIcon"
               name: @attrs.rightIcon
