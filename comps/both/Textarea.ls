Textarea = m.comp do
   onbeforeupdate: !->
      @attrs.resize ?= \none
      @attrs.rows ?= 4

   oncreate: !->
      if @attrs.autoFocus
         @dom.focus!

   oninput: (event) !->
      @attrs.onchange? event

   oncontextmenuInput: (event) !->
      os.addContextMenu event,
         *  beginGroup: \TextInput
         *  text: "Hoàn tác"
            icon: \arrow-rotate-left
            click: !~>
               @dom.focus!
               document.execCommand \undo
         *  text: "Làm lại"
            icon: \arrow-rotate-right
            click: !~>
               @dom.focus!
               document.execCommand \redo
         ,,
         *  text: "Cắt"
            icon: \scissors
            click: !~>
               @dom.focus!
               document.execCommand \cut
         *  text: "Sao chép"
            icon: \copy
            click: !~>
               @dom.focus!
               document.execCommand \copy
         *  text: "Dán"
            icon: \paste
            click: !~>
               @dom.focus!
               text = await navigator.clipboard.readText!
               document.execCommand \insertText,, text
         ,,
         *  text: "Chọn tất cả"
            click: !~>
               @dom.focus!
               document.execCommand \selectAll
      @attrs.oncontextmenu? event

   view: ->
      m \textarea.Textarea,
         class: m.class do
            "disabled": @attrs.disabled
            "Textarea--fill": @attrs.fill
            @attrs.class
         style: m.style do
            resize: @attrs.resize
            @attrs.style
         name: @attrs.name
         disabled: @attrs.disabled
         minLength: @attrs.minLength
         maxLength: @attrs.maxLength
         pattern: @attrs.pattern
         required: @attrs.required
         placeholder: @attrs.placeholder
         oninput: @oninput
         oncontextmenu: @oncontextmenuInput
         value: @attrs.value
