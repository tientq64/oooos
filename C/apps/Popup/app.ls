App = m.comp do
   oninit: !->
      @type = os.args.type
      @opts = os.args.opts or {}
      @message = os.args.message
      @updateMessage!
      @val = @opts.defaultValue
      @willFitContentSize = yes

   onupdate: !->
      if @willFitContentSize
         os.fitContentSize!
         @willFitContentSize = no

   updateMessage: !->
      if @opts.isMarkdown
         @message = os.escapeHtml @message
         @message = marked.parse @message,
            silent: yes
         m.redraw!

   onchangeInput: (event) !->
      @val = event.target.value
      @willFitContentSize = yes

   onsubmit: (event) !->
      event.preventDefault!
      switch @type
      | \confirm
         os.close yes
      | \prompt
         os.close @val
      else
         os.close!

   onclickNo: (event) !->
      os.close no

   onclickCancel: (event) !->
      os.close!

   view: ->
      m \form.column.h-100.gap-3.p-3,
         onsubmit: @onsubmit
         m \.Popup-message.col.ov-auto,
            if @opts.isMarkdown
               m.trust @message
            else
               @message
         if @type == \prompt
            m TextInput,
               fill: yes
               autoFocus: yes
               value: @val
               onchange: @onchangeInput
         m \.text-right,
            m InputGroup,
               m Button,
                  type: \submit
                  width: 80
                  color: \blue
                  "OK"
               if @type == \confirm
                  m Button,
                     width: 80
                     color: \red
                     onclick: @onclickNo
                     "Không"
               if @type == \prompt or (@type == \confirm and @opts.cancelable)
                  m Button,
                     width: 80
                     onclick: @onclickCancel
                     "Hủy"
