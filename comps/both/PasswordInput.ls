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
            "PasswordInput--fill": @attrs.fill
            "PasswordInput--isHidePassword": @isHidePassword
            "PasswordInput"
            @attrs.class
         style: m.style do
            @attrs.style
         fill: @attrs.fill
         disabled: @attrs.disabled
         @textInput =
            m TextInput,
               name: @attrs.name
               minLength: @attrs.minLength
               maxLength: @attrs.maxLength
               pattern: @attrs.pattern
               required: @attrs.required
               autoFocus: @attrs.autoFocus
               readOnly: @attrs.readOnly
               placeholder: @attrs.placeholder
               value: @attrs.value
               icon: @attrs.icon
               rightIcon: @attrs.rightIcon
               tooltip: @attrs.tooltip
               onchange: @attrs.onchange
               oncontextmenu: @oncontextmenuTextInput
         m Button,
            icon: @isHidePassword and \eye or \eye-slash
            tooltip: "#{@isHidePassword and \Hiện or \Ẩn} mật khẩu|right,top,bottom,"
            onclick: @onclickIsHidePassword
