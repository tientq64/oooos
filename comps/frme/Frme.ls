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
         createDir
         readDir
         deleteDir
         readFile
         writeFile
         deleteFile
         requestTaskPerm
         runTask
         setDesktopBgImagePath
         minimize
         maximize
         close
         initTaskFrme
         mousedownFrme
         startListen
         showSubmenuMenu
         closeSubmenuMenu
         showContextMenu
         showMenubarMenu
         closeMenubarMenu
      ]>
      for let methodName in methodNames
         method = (...args) ->
            @sendFTF methodName, ...args
         @[methodName] = method.bind @

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Frme-body

      window.addEventListener \mousedown @onmousedownGlobal
      window.addEventListener \message @onmessageGlobal

   addListener: (name, callback, isResponder) !->
      listener = @listeners[name]
      unless listener
         listener =
            responder: void
            callbacks: []
         @listeners[name] = listener
      if isResponder
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

   onmousedownGlobal: (event) !->
      if event.isTrusted
         eventData = event{clientX, clientY, screenX, screenY, buttons}
         os.mousedownFrme eventData

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
               m.redraw!
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
            m.redraw!
         | \ta
            {mid, pid, name, val} = data
            if name.0 == \$
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
         m \.Frme-body
