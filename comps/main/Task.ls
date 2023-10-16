class Task extends Both
   (app, env = {}) ->
      super!

      @isMain = yes
      @isTask = yes

      @app = app
      @name = app.name
      @path = app.path
      @appDataPath = app.appDataPath
      @type = app.type
      @icon = app.icon

      @pid = os.getIncrId!
      @tid = @randomUuid!
      @title = String env.title ? app.title ? @name
      @minWidth$ = Number env.minWidth ? app.minWidth or 200
      @minHeight$ = Number env.minHeight ? app.minHeight or 80
      @updateMinSize!
      @maxWidth$ = Number env.maxWidth ? app.maxWidth or void
      @maxHeight$ = Number env.maxHeight ? app.maxHeight or void
      @updateMaxSize!
      @width = Number env.width ? app.width or 800
      @height = Number env.height ? app.height or 600
      @updateSize!
      @x = Number env.x ? app.x or (os.desktopWidth - @width) / 2
      @y = Number env.y ? app.y or (os.desktopHeight - @height) / 2
      @updateXY!
      @minimized = Boolean env.minimized ? app.minimized ? no
      @maximized = Boolean env.maximized ? app.maximized ? no
      @fullscreen = Boolean env.fullscreen ? app.fullscreen ? no
      @noHeader$ = Boolean env.noHeader ? app.noHeader ? no
      @updateNoHeader!
      @autoListen = Boolean env.autoListen ? app.autoListen ? yes
      @args = env.args or app.args or {}

      @closedResolve = void
      @closed = new Promise (@closedResolve) !~>
      @listenedResolve = void
      @listened = new Promise (@listenedResolve) !~>
      @moving = no
      @bodyEl = void
      @frameEl = void
      @postMessage = void

      os.tasks.push @

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Task-body
      @updateSizeDom!
      @updateXYDom!

      if @fullscreen
         @setFullscreen yes

      unless @isOS
         importVar = eval importVarCode
         code = await os.readFile "#@path/app.ls"
         code = importVar codeF
         code = importVar codeB
         code = livescript.compile code
         styl = ""
         try styl = await os.readFile "#@path/app.styl"
         styl = importVar stylF
         styl = importVar stylB
         styl = stylus.render styl, compress: yes
         html = importVar htmlF
         html .= replace /<!-- Code injected by live-server -->.+<\/script>/s ""
         frameEl = document.createElement \iframe
         frameEl.className = \Task-frame
         frameEl.srcdoc = html
         @bodyEl.appendChild frameEl
         @frameEl = frameEl

      m.redraw!

   makeEnt: (ent) ->
      stat = await fs.stat ent
      {children} = ent
      ent =
         name: stat.name
         path: stat.fullPath
         isDir: stat.isDirectory
         isFile: stat.isFile
         mtime: Number stat.modificationTime
         size: stat.size
      if ent.isFile
         ent.ext = @extPath ent.name
      if children
         ent.children = await Promise.all children.map (@makeEnt <|)
      ent

   getEnt: (path) ->
      ent = await fs.getEntry path
      @makeEnt ent

   existsEnt: (path) ->
      path = @castPath path
      fs.exists path

   moveEnt: (path, newPath, isCreate) ->
      path = @castPath path
      newPath = @castPath newPath
      ent = await fs.rename path, newPath,
         create: isCreate
      @makeEnt ent

   copyEnt: (path, newPath, isCreate) ->
      path = @castPath path
      newPath = @castPath newPath
      ent = await fs.copy path, newPath,
         create: isCreate
      @makeEnt ent

   createDir: (path) ->
      dir = await fs.mkdir path
      @makeEnt dir

   readDir: (path, isDeep) ->
      path = @castPath path
      dirs = await fs.readdir path,
         deep: isDeep
      Promise.all dirs.map (@makeEnt <|)

   deleteDir: (path) ->
      path = @castPath path
      result = await fs.rmdir path
      result == void

   readFile: (path, type) ->
      path = @castPath path
      type ?= \text
      type = @upperFirst type
      fs.readFile path, type

   writeFile: (path, data) ->
      path = @castPath path
      file = await fs.writeFile path, data
      @makeEnt file

   deleteFile: (path) ->
      path = @castPath path
      result = await fs.unlink path
      result == void

   installApp: (installType, sourcePath, path, appDataPath) !->
      switch installType
      | \boot
         yaml = await m.fetch "#sourcePath/app.yml"
         pack = jsyaml.safeLoad yaml
         app =
            name: pack.name
            path: path
            appDataPath: appDataPath
            type: pack.type or \normal
            icon: pack.icon or \square-dashed
            minWidth: pack.minWidth
            minHeight: pack.minHeight
            maxWidth: pack.maxWidth
            maxHeight: pack.maxHeight
            width: pack.width
            height: pack.height
            x: pack.x
            y: pack.y
            minimized: pack.minimized
            maximized: pack.maximized
            fullscreen: pack.fullscreen
            noHeader: pack.noHeader
            autoListen: pack.autoListen
         code = await m.fetch "#sourcePath/app.ls"
         await os.writeFile "#path/app.ls" code
         try
            styl = await m.fetch "#sourcePath/app.styl"
            await os.writeFile "#path/app.styl" styl
         await os.writeFile "#path/app.yml" yaml
         os.apps.push app
      m.redraw!

   createAppPerms: (app) ->
      perms =
         *  name: \desktopBgView
            status: \ask
         *  name: \desktopBgEdit
            status: \ask
         *  name: \filesView
            status: \ask
            paths:
               *  path: app.appDataPath
                  status: \granted
               ...
         *  name: \filesEdit
            status: \ask
            paths:
               *  path: app.appDataPath
                  status: \granted
               ...
      perms

   runTask: (name, env) ->
      app = os.apps.find (.name == name)
      if app
         task = new Task app, env
         task.pid

   waitListenedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.listened

   waitClosedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.closed

   minimize: (val) !->
      val = Boolean val ? !@minimized
      if val != @minimized
         @minimized = val
         m.redraw!

   maximize: (val) !->
      val = Boolean val ? !@maximized
      if val != @maximized
         @maximized = val
         m.redraw!

   setFullscreen: (val) !->
      val = Boolean val ? !@fullscreen
      if val != @fullscreen
         @fullscreen = val
         @updateNoHeader!
         m.redraw!

   close: (val) !->
      if @closedResolve
         if @listenedResolve
            @listenedResolve no
            @listenedResolve = void
         @closedResolve val
         @closedResolve = void
         index = os.tasks.indexOf @
         os.tasks.splice index, 1
         m.redraw!

   updateMinSize: !->
      @minWidth = @clamp @minWidth$, 200 os.desktopWidth
      @minHeight = @clamp @minHeight$, 80 os.desktopHeight

   updateMaxSize: !->
      @maxWidth = @clamp @maxWidth$ ? os.desktopWidth, @minWidth, os.desktopWidth
      @maxHeight = @clamp @maxHeight$ ? os.desktopHeight, @minHeight, os.desktopHeight

   updateSize: !->
      @width = @clamp @width, @minWidth, @maxWidth
      @height = @clamp @height, @minHeight, @maxHeight

   updateXY: !->
      @x = @clamp @x, 0 os.desktopWidth - @width
      @y = @clamp @y, 0 os.desktopHeight - @height

   updateNoHeader: !->
      @noHeader = @noHeader$ or @fullscreen

   updateSizeDom: !->
      @dom.style <<< m.style do
         width: @width
         height: @height

   updateXYDom: !->
      @dom.style <<< m.style do
         left: @x
         top: @y

   sendTF: (name, ...args) !->
      if @postMessage
         @postMessage do
            type: \tf
            name: name
            args: args
            \*

   sendTA: (name, ...args) !->
      if @postMessage
         @postMessage do
            type: \ta
            name: name
            args: args
            \*

   addRectXYByFrameEl: (rect) !->
      frameRect = @frameEl.getBoundingClientRect!
      rect.x += frameRect.x
      rect.y += frameRect.y
      rect.left = rect.x
      rect.top = rect.y
      rect.right += frameRect.x
      rect.bottom += frameRect.y

   initTaskFrme: ->
      @tid = @randomUuid!
      @postMessage = @frameEl.contentWindow~postMessage
      tid: @tid
      autoListen: @autoListen
      args: @args

   mousedownFrme: (eventData) !->
      frameRect = @frameEl.getBoundingClientRect!
      eventData.clientX += frameRect.x
      eventData.clientY += frameRect.y
      mouseEvent = new MouseEvent \mousedown eventData
      document.dispatchEvent mouseEvent
      eventData.clientX = -1
      eventData.clientY = -1
      for task in os.tasks
         unless task == @
            task.sendTF \mousedownMain eventData

   startListen: (val) !->
      if @listenedResolve
         val ?= yes
         @listenedResolve val
         @listenedResolve = void

   showMenu: (rect, items, isAddFrameXY, popperClassName, popperOpts) ->
      resolve = void
      if isAddFrameXY
         @addRectXYByFrameEl rect
      targetEl =
         getBoundingClientRect: ~>
            rect
      popperEl = document.createElement \div
      popperEl.className = "OS-menuPopper #popperClassName"
      popperEl.addEventListener \mousedown @stopPropagation
      portalEl = os.dom
      portalEl.appendChild popperEl
      m.mount popperEl,
         view: ~>
            m Menu,
               isSubmenu: yes
               basic: yes
               items: items
               onSubmenuItemClick: (item) !~>
                  close item
      popper = os.createPopper targetEl, popperEl, popperOpts
      close = (item) !~>
         if popper
            m.mount popperEl
            popperEl.remove!
            popper.destroy!
            popper := void
            document.removeEventListener \mousedown onmousedownGlobal
            resolve item
      onmousedownGlobal = (event) !~>
         unless popperEl.contains event.target
            close!
      document.addEventListener \mousedown onmousedownGlobal
      closed = new Promise (resolve2) !~>
         resolve := resolve2
      [close, closed]

   showSubmenuMenu: (rect, items, isAddFrameXY) ->
      [close, closed] = @showMenu rect, items, isAddFrameXY, \OS-submenuMenu,
         placement: \right-start
         offset: [-4 -2]
      os.submenuMenuClose = close
      closed

   closeSubmenuMenu: !->
      if os.submenuMenuClose
         os.submenuMenuClose!
         os.submenuMenuClose = void

   showContextMenu: (x, y, items, isAddFrameXY) ->
      rect = @makeRectFromXY x, y
      [close, closed] = @showMenu rect, items, isAddFrameXY, \OS-contextMenu,
         placement: \right-start
         offset: [-1 -1]
      os.contextMenuClose = close
      closed

   closeContextMenu: !->
      if os.contextMenuClose
         os.contextMenuClose!
         os.contextMenuClose = void

   onpointerdownTitle: (event) !->
      if event.buttons == 1
         event.target.setPointerCapture event.pointerId
         @moving = yes

   onpointermoveTitle: (event) !->
      event.redraw = no
      if @moving
         @x += event.movementX
         @y += event.movementY
         @updateXYDom!

   onlostpointercaptureTitle: (event) !->
      @moving = no
      @updateXY!
      @updateXYDom!

   onclickMinimize: (event) !->
      @minimize!

   onclickMaximize: (event) !->
      @maximize!

   onclickClose: (event) !->
      @close!

   view: (vnode, vdom) ->
      m \.Task,
         class: m.class do
            "Task--minimized": @minimized
            "Task--maximized": @maximized
            "Task--fullscreen": @fullscreen
            "Task--noHeader": @noHeader
         m \.Task-header,
            inert: @noHeader
            m \.Task-title,
               onpointerdown: @onpointerdownTitle
               onpointermove: @onpointermoveTitle
               onlostpointercapture: @onlostpointercaptureTitle
               m Icon,
                  class: "mr-2"
                  name: @icon
               @title
            m \.Task-actions,
               m Button,
                  basic: yes
                  small: yes
                  icon: \minus
                  onclick: @onclickMinimize
               m Button,
                  basic: yes
                  small: yes
                  icon: \plus
                  onclick: @onclickMaximize
               m Button,
                  basic: yes
                  small: yes
                  color: \red
                  icon: \xmark
                  onclick: @onclickClose
         m \.Task-body,
            if vdom
               m \.Task-frame,
                  vdom
