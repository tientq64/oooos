PasswordInput = m.comp do
   oninit: !->
      @isHidePassword = yes
      @textInput = void

   oncontextmenuTextInput: (event) !->
      os.addContextMenu event,
         *  text: "#{@isHidePassword and \Hiện or \Ẩn} mật khẩu"
            icon: @isHidePassword and \eye or \eye-slash
            click: !~>
               @textInput.state.input.dom.focus!
               != @isHidePassword
         ,,
         *  includeGroup: \TextInput

      @attrs.oncontextmenu? event

   onclickIsHidePassword: (event) !->
      != @isHidePassword

   view: ->
      m InputGroup,
         class:
            "PasswordInput--isHidePassword": @isHidePassword
            "PasswordInput"
            @attrs.class
         style: m.style do
            @attrs.style
         fill: @attrs.fill
         @textInput =
            m TextInput,
               name: @attrs.name
               disabled: @attrs.disabled
               minLength: @attrs.minLength
               maxLength: @attrs.maxLength
               pattern: @attrs.pattern
               required: @attrs.required
               autoFocus: @attrs.autoFocus
               placeholder: @attrs.placeholder
               value: @attrs.value
               onchange: @attrs.onchange
               oncontextmenu: @oncontextmenuTextInput
         m Button,
            icon: @isHidePassword and \eye or \eye-slash
            onclick: @onclickIsHidePassword
