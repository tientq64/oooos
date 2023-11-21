NumberInput = m.comp do
   oninit: !->
      @controlled = \value of @attrs
      @value = @attrs.value
      @spinTimeoutId = void
      @spinIntervalId = void
      @isOnchange = no

   onbeforeupdate: !->
      if @controlled
         unless @isOnchange
            @value = @attrs.value
      @isOnchange = no

   spin: (amount) !->
      @input.dom.stepUp amount
      num = @input.dom.valueAsNumber
      @value = num
      @isOnchange = yes
      os.safeSyncCall @attrs.onValueChange, num
      m.redraw!

   onchangeTextInput: (event) !->
      val = event.target.value
      @value = val
      @isOnchange = yes
      @input.dom.value = val
      num = @input.dom.valueAsNumber
      unless isNaN num
         os.safeSyncCall @attrs.onValueChange, num

   oncontextmenuTextInput: (event) !->
      os.addContextMenu event,
         *  text: "Tăng lên"
            icon: \angle-up
            click: !~>
               @spin 1
         *  text: "Giảm xuống"
            icon: \angle-down
            click: !~>
               @spin -1
         ,,
         *  includeGroup: \TextInput

   onpointerdownSpin: (amount, event) !->
      event.target.setPointerCapture event.pointerId
      @spin amount
      @spinTimeoutId = setTimeout !~>
         @spin amount
         @spinIntervalId = setInterval !~>
            @spin amount
         , 50
      , 250

   onlostpointercaptureSpin: (event) !->
      clearTimeout @spinTimeoutId
      clearInterval @spinIntervalId

   view: ->
      m InputGroup,
         class:
            "NumberInput--fill": @attrs.fill
            "NumberInput"
            @attrs.class
         style:
            @attrs.style
         fill: @attrs.fill
         disabled: @attrs.disabled
         @textInput =
            m TextInput,
               class: "NumberInput-textInput"
               autoFocus: @attrs.autoFocus
               readOnly: @attrs.readOnly
               placeholder: @attrs.placeholder
               value: @value
               icon: @attrs.icon
               rightIcon: @attrs.rightIcon
               tooltip: @attrs.tooltip
               onchange: @onchangeTextInput
               oncontextmenu: @oncontextmenuTextInput
         @input =
            m \input.NumberInput-input,
               name: @attrs.name
               type: \number
               min: @attrs.min
               max: @attrs.max
               step: @attrs.step
               pattern: @attrs.pattern
               required: @attrs.required
               value: @value
         m \.NumberInput-spins,
            m Button,
               class: "NumberInput-spin NumberInput-spinUp"
               icon: \angle-up
               onpointerdown: @onpointerdownSpin.bind void 1
               onlostpointercapture: @onlostpointercaptureSpin
            m Button,
               class: "NumberInput-spin NumberInput-spinDown"
               icon: \angle-down
               onpointerdown: @onpointerdownSpin.bind void -1
               onlostpointercapture: @onlostpointercaptureSpin
