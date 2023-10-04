class Frme extends Both
   ->
      super!

      @tid = void

      @dom = void
      @bodyEl = void
      @resolvers = {}
      @listeners = {}

      @initFTFMethods!

   initFTFMethods: !->
      methodNames = <[
         initTaskFrme
         mousedownFrme
         startListen
         showSubmenu
         closeSubmenu
      ]>
      for let methodName in methodNames
         method = (...args) ->
            @sendFTF methodName, ...args
         @[methodName] = method.bind @

   oncreate: (vnode) !->
      @dom = vnode.dom
      @bodyEl = @dom.querySelector \.Frme-body

      window.addEventListener \mousedown @onmousedownGlobal, yes
      window.addEventListener \message @onmessageGlobal

   addListener: (name, callback) !->
      listener = @listeners[][name]
      listener.push callback

   removeListener: (name, callback) !->
      if listener = @listeners[name]
         index = listener.indexOf callback
         listener.splice index, 1

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
            {mid, name, args} = data
            method = @[name]
            method.apply void args
            m.redraw!
         | \ta
            if listener = @listeners[name]
               for callback in listener
                  try
                     callback.apply void args
                  catch
                     console.error e
               m.redraw!

   sendFTF: (name, ...args) ->
      new Promise (resolve, reject) !~>
         mid = @randomUuid!
         resolver =
            resolve: resolve
            reject: reject
         @resolvers[mid] = resolver
         parent.postMessage do
            type: \ftf
            mid: mid
            tid: @tid
            name: name
            args: args
            \*

   view: ->
      m \.Frme,
         m \.Frme-body
