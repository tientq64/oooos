class Frme extends Both
   ->
      super!

      @isFrme = yes

      @tid = void
      @args = void

      @bodyEl = void
      @listeners = {}

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
         requestTaskPerm
         runTask
         closeTask
         setDesktopBgImagePath
         minimize
         maximize
         setFullscreen
         show
         alert
         confirm
         prompt
         close
         initTaskFrme
         loadedTaskFrme
         mousedownFrme
         startListen
         showSubmenuMenu
         closeSubmenuMenu
         showContextMenu
         showMenubarMenu
         closeMenubarMenu
         showTooltip
         closeTooltip
      ]>
      for let methodName in methodNames
         method = (...args) ->
            @sendFTF methodName, ...args
         @[methodName] = method.bind @

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Frme-body

      window.addEventListener \mouseover @onmouseoverGlobal
      window.addEventListener \mousedown @onmousedownGlobal
      window.addEventListener \message @onmessageGlobal

   fitContentSize: !->
      os.dom.classList.add \Frme--useContentSize
      {width, height} = @bodyEl.getBoundingClientRect!
      os.dom.classList.remove \Frme--useContentSize
      await @sendFTF \fitContentSize width, height

   addListener: (name, callback, isResponder) !->
      listener = @listeners[name]
      unless listener
         listener =
            responder: void
            callbacks: []
         @listeners[name] = listener
      if isResponder or listener.callbacks.length == 0
         listener.responder = callback
      else
         listener.callbacks.push callback

   removeListener: (name, callback) !->
      if listener = @listeners[name]
         if listener.responder == callback
            listener.responder = void
         index = listener.callbacks.indexOf callback
         listener.callbacks.splice index, 1

   mousedownMain: (eventData) !->
      mouseEvent = new MouseEvent \mousedown eventData
      document.dispatchEvent mouseEvent

   onmouseoverGlobal: (event) !->
      if event.isTrusted
         if el = event.target.closest "[tooltip]"
            rect = @getRect el
            text = el.getAttribute \tooltip
            @showTooltip rect, text, yes
         else
            @closeTooltip!

   onmousedownGlobal: (event) !->
      if event.isTrusted
         eventData = event{clientX, clientY, screenX, screenY, buttons}
         os.mousedownFrme eventData
         @closeTooltip!

   onmessageGlobal: (event) !->
      if data = event.data
         {type} = data
         switch type
         | \ftf
            {mid, result, isErr} = data
            if resolver = @resolvers[mid]
               delete @resolvers[mid]
               methodName = isErr and \reject or \resolve
               resolver[methodName] result
         | \tf
            {mid, pid, name, args} = data
            method = @[name]
            [result, isErr] = await @safeAsyncApply method, args
            parent.postMessage do
               type: \tf
               mid: mid
               pid: pid
               result: result
               isErr: isErr
               \*
         | \ta
            {mid, pid, name, val} = data
            if name.0 == \$
               if name.1 == \$
                  name .= substring 1
               else
                  propName = name.substring 1
                  os[propName] = val
            if listener = @listeners[name]
               for callback in listener.callbacks
                  @safeSyncCall callback, val
               if listener.responder
                  [result, isErr] = await @safeAsyncCall listener.responder, val
            parent.postMessage do
               type: \ta
               mid: mid
               pid: pid
               result: result
               isErr: isErr
               \*
            m.redraw!

   sendFTF: (name, ...args) ->
      [mid, promise] = @addResolver!
      parent.postMessage do
         type: \ftf
         mid: mid
         tid: @tid
         name: name
         args: args
         \*
      promise

   view: ->
      m \.Frme.Portal,
         class: m.class do
            "Frme--useContentSize": @useContentSize
         m \.Frme-body
