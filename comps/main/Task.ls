class Task extends Both
   (app, env = {}) ->
      super!

      @isMain = yes
      @isTask = yes

      @app = app
      @env = env
      @name = app.name
      @path = app.path
      @appDataPath = app.appDataPath
      @type = app.type
      @icon = app.icon

      @pid = os.getIncrId!
      @tid = os.randomUuid!
      @title = String env.title ? app.title ? @name
      @initMinSize app, env
      @updateMinSize!
      @initMaxSize app, env
      @updateMaxSize!
      @width = Number env.width ? app.width or 800
      @height = Number env.height ? app.height or 600
      @updateSize!
      @x = Number env.x ? app.x or (os.desktopWidth - @width) / 2
      @y = Number env.y ? app.y or (os.desktopHeight - @height) / 2
      @updateXY!
      @minimized = Boolean env.minimized ? app.minimized ? no
      @maximized = Boolean env.maximized ? app.maximized ? no
      @isFullscreen = Boolean env.isFullscreen ? app.isFullscreen ? no
      @noHeader = Boolean env.noHeader ? app.noHeader ? no

      @closedResolve = void
      @closed = new Promise (@closedResolve) !~>
      @listenedResolve = void
      @listened = new Promise (@listenedResolve) !~>
      @moving = no
      @bodyEl = void
      @frameEl = void
      @postMessage = void

      os.tasks.push @

   initMinSize: (app, env) !->
      minWidth = env.minWidth ? app.minWidth
      minHeight = env.minHeight ? app.minHeight
      @isFullMinWidth = minWidth == \full
      @isFullMinHeight = minHeight == \full
      @minWidth = Number minWidth or 200
      @minHeight = Number minHeight or 80

   initMaxSize: (app, env) !->
      maxWidth = env.maxWidth ? app.maxWidth
      maxHeight = env.maxHeight ? app.maxHeight
      @isFullMaxWidth = isNaN maxWidth
      @isFullMaxHeight = isNaN maxHeight
      @maxWidth = Number maxWidth or os.desktopWidth
      @maxHeight = Number maxHeight or os.desktopHeight

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Task-body
      @updateRectDom!

      unless @isOS
         importVar = eval importVarCode
         code = await os.readFile "#@path/app.ls"
         code = importVar codeF
         code = importVar codeB
         code = livescript.compile code
         try
            styl = await os.readFile "#@path/app.styl"
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
            isFullscreen: pack.isFullscreen
            noHeader: pack.noHeader
         code = await m.fetch "#sourcePath/app.ls"
         await os.writeFile "#path/app.ls" code
         try
            styl = await m.fetch "#sourcePath/app.styl"
            await os.writeFile "#path/app.styl" styl
         await os.writeFile "#path/app.yml" yaml
         os.apps.push app
      m.redraw!

   runTask: (name, env) ->
      app = os.apps.find (.name == name)
      if app
         task = new Task app, env
         task.pid

   minimize: (val) !->
      val = Boolean val ? !@minimized
      @minimized = val
      m.redraw!

   maximize: (val) !->
      val = Boolean val ? !@maximized
      @maximized = val
      m.redraw!

   close: (val) !->
      if @closedResolve
         @closedResolve val
         @closedResolve = void
         index = os.tasks.indexOf @
         os.tasks.splice index, 1
         m.redraw!

   updateMinSize: !->
      if @isFullMinWidth
         @minWidth = os.desktopWidth
      @minWidth = @clamp @minWidth, 200 os.desktopWidth
      if @isFullMinHeight
         @minHeight = os.desktopHeight
      @minHeight = @clamp @minHeight, 80 os.desktopHeight

   updateMaxSize: !->
      if @isFullMaxWidth
         @maxWidth = os.desktopWidth
      @maxWidth = @clamp @maxWidth, @minWidth, os.desktopWidth
      if @isFullMaxHeight
         @maxHeight = os.desktopHeight
      @maxHeight = @clamp @maxHeight, @minHeight, os.desktopHeight

   updateSize: !->
      @width = @clamp @width, @minWidth, @maxWidth
      @height = @clamp @height, @minHeight, @maxHeight

   updateXY: !->
      @x = @clamp @x, 0 os.desktopWidth - @width
      @y = @clamp @y, 0 os.desktopHeight - @height

   updateSizeDom: !->
      @dom.style <<< m.style do
         width: @width
         height: @height

   updateXYDom: !->
      @dom.style <<< m.style do
         left: @x
         top: @y

   updateRectDom: !->
      @updateSizeDom!
      @updateXYDom!

   resizeTask: !->
      @updateMinSize!
      @updateMaxSize!
      @updateSize!
      @updateXY!
      @updateRectDom!

   sendTF: (name, ...args) !->
      @postMessage do
         type: \tf
         name: name
         args: args
         \*

   sendTA: (name, ...args) !->
      @postMessage do
         type: \ta
         name: name
         args: args
         \*

   addRectXYByFrameEl: (rect) !->
      frameRect = @frameEl.getBoundingClientRect!
      x = rect.x + frameRect.x
      y = rect.y + frameRect.y
      rect.x = x
      rect.y = y
      rect.left = x
      rect.top = y
      rect.right += frameRect.x
      rect.bottom += frameRect.y

   initTaskFrme: ->
      @tid = @randomUuid!
      @postMessage = @frameEl.contentWindow~postMessage
      tid: @tid

   mousedownFrme: (eventData) !->
      frameRect = @frameEl.getBoundingClientRect!
      eventData.clientX += frameRect.x
      eventData.clientY += frameRect.y
      mouseEvent = new MouseEvent \mousedown eventData
      document.dispatchEvent mouseEvent

   startListen: !->
      if @listenedResolve
         @listenedResolve!
         @listenedResolve = void

   showSubmenu: (rect, items) ->
      new Promise (resolve) !~>
         @addRectXYByFrameEl rect
         targetEl = os.makeFakePopperTargetEl rect
         comp =
            view: ->
               m Menu,
                  isSubmenu: yes
                  basic: yes
                  items: items
         popperEl = document.createElement \div
         popperEl.className = "Menu-submenu"
         os.portalsEl.appendChild popperEl
         m.mount popperEl, comp
         os.submenuPopper = os.createPopper targetEl, popperEl,
            placement: \right-start
            offset: [-4 -2]
         document.addEventListener \mousedown os.onmousedownGlobalSubmenu
         os.submenuResolve = resolve

   closeSubmenu: (item) !->
      if os.submenuPopper
         os.submenuPopper.state.elements.popper.remove!
         os.submenuPopper.destroy!
         os.submenuPopper = void
         document.removeEventListener \mousedown os.onmousedownGlobalSubmenu
         os.submenuResolve item

   onmousedownGlobalSubmenu: (event) !->
      popperEl = os.submenuPopper.state.elements.popper
      unless popperEl.contains event.target
         os.closeSubmenu!

   showContextMenu: (x, y, items, isAddFrameXY) ->
      if isAddFrameXY
         rect = @frameEl.getBoundingClientRect!
         x += rect.x
         y += rect.y
      targetEl = os.makeFakePopperTargetElByXY x, y
      comp =
         view: ->
            m Menu
      new Promise (resolve) !~>
         targetEl = os.makeFakePopperTargetEl rect
         os.contextMenuResolve = resolve

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
            "Task--isFullscreen": @isFullscreen
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
