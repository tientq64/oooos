class Frme extends Both
   ->
      super!

      @isFrme = yes

      @tid = void
      @args = void

      @bodyEl = void
      @listeners = {}
      @answerers = {}
      @listened = no

      @initFTFMethods!

   initFTFMethods: !->
      methodNames = <[
         getEnt
         existsEnt
         moveEnt
         copyEnt
         openEnt
         openWithEnt
         createDir
         readDir
         deleteDir
         readFile
         writeFile
         deleteFile
         requestPerm
         runTask
         focusTask
         closeTask
         setTaskbarPosition
         setTaskbarPositionLocked
         setDesktopBgImageFit
         setDesktopBgImagePath
         minimize
         maximize
         setFullscreen
         setDarkMode
         show
         alert
         confirm
         prompt
         close
         initTaskFrme
         loadedFrme
         mousedownFrme
         showSubmenuMenu
         closeSubmenuMenu
         showContextMenu
         showMenubarMenu
         closeMenubarMenu
         showSelectMenu
         closeSelectMenu
         showTooltip
         closeTooltip
      ]>
      for let methodName in methodNames
         method = (...args) ->
            @send \callWait methodName, ...args
         @[methodName] = method.bind @

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Frme-body

      window.addEventListener \mouseover @onmouseoverGlobal
      window.addEventListener \mousedown @onmousedownGlobal
      window.addEventListener \message @onmessageGlobal

   fitContentSize: ->
      os.dom.classList.add \Frme--useContentSize
      {width, height} = @bodyEl.getBoundingClientRect!
      os.dom.classList.remove \Frme--useContentSize
      @send \callWait \fitContentSize width, height

   startListen: ->
      @listened = yes
      @send \callWait \startListen yes

   addListener: (name, callback) !->
      if @isFunc callback
         listener = @listeners[name]
         unless listener
            listener =
               callbacks: []
            @listeners[name] = listener
         listener.callbacks.push callback

   removeListener: (name, callback) !->
      if @isFunc callback
         if listener = @listeners[name]
            @removeArr listener.callbacks, callback

   setAnswerer: (name, callback) !->
      if @isFunc
         @answerers[name] = callback
      else
         delete @answerers[name]

   mousedownMain: (eventData) !->
      mouseEvent = new MouseEvent \mousedown eventData
      document.dispatchEvent mouseEvent

   closeFrme: !->
      setTimeout !~>
         m.mount os.bodyEl
         m.mount document.body
      , 400

   onmouseoverGlobal: (event) !->
      if event.isTrusted
         if el = event.target.closest "[tooltip]"
            rect = @getRect el
            text = el.getAttribute \tooltip
            isDark = @checkElIsDark el
            @showTooltip rect, text, isDark, yes
         else
            @closeTooltip!

   onmousedownGlobal: (event) !->
      if event.isTrusted
         eventData = event{clientX, clientY, screenX, screenY, buttons}
         os.mousedownFrme eventData
         @closeTooltip!

   onmessageGlobal: (event) !->
      if !event.isTrusted or event.origin == \null or !event.data
         return
      {flow, act, mid, pid, name, vals, result, isErr} = event.data
      switch flow
      | \fmf
         @resolveResolver mid, result, isErr
      | \mfm
         isWait = no
         switch act
         | \call
            isCall = yes
            method = @[name]
         | \set
            isSet = yes
            isRedraw = yes
         | \emit
            isEmit = yes
            isRedraw = yes
            listener = @listeners[name]
         | \ask
            isCall = yes
            isCallIfIsFunc = yes
            isWait = yes
            isRedraw = yes
            method = @answerers[name]
         | \perm
            isSet = yes
            isEmit = yes
            isRedraw = yes
            listener = @listeners[name]
         if isSet
            @[name] = vals.0
         if isEmit
            if listener = @listeners[name]
               for callback in listener.callbacks
                  @safeSyncCall callback, vals.0
         if isRedraw
            m.redraw!
         if isCall
            if @isFunc method or !isCallIfIsFunc
               try
                  res = method ...vals
                  if res instanceof Promise
                     if isWait
                        result = await res
                  else
                     result = res
               catch
                  result = e
                  isErr = yes
         if isRedraw
            m.redraw!
         parent.postMessage do
            flow: flow
            mid: mid
            pid: pid
            result: result
            isErr: isErr
            \*

   send: (act, name, ...vals) ->
      [mid, promise] = @addResolver!
      parent.postMessage do
         flow: \fmf
         act: act
         mid: mid
         tid: @tid
         name: name
         vals: vals
         \*
      promise

   view: ->
      m \.Frme.Portal,
         class: m.class do
            "dark": @darkMode
            "minimized": @minimized
            "maximized": @maximized
            "fullscreen": @fullscreen
            "Frme--useContentSize": @useContentSize
         style: m.style do
            "--fontSans": @fontSans
            "--fontSerif": @fontSerif
            "--fontMono": @fontMono
            "--textSize": @textSize
            "--textContrast": @textContrast
         m \.Frme-body
