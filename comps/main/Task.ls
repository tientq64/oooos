class Task extends Both
   (app, env = {}) ->
      super!

      @isMain = yes
      @isTask = yes

      @app = app
      @name = app.name
      @path = app.path
      @type = app.type
      @icon = app.icon
      @version = app.version
      @author = app.author
      @description = app.description
      @license = app.license

      @pid = os.getIncrId!
      @tid = @randomUuid!
      @admin = Boolean env.admin ? app.admin ? no
      @title = String env.title ? app.title ? @name
      @focusable = Boolean env.focusable ? app.focusable ? yes
      @minWidth$ = Number env.minWidth ? app.minWidth or 200
      @minHeight$ = Number env.minHeight ? app.minHeight or 80
      @updateMinSize!
      @maxWidth$ = Number env.maxWidth ? app.maxWidth or void
      @maxHeight$ = Number env.maxHeight ? app.maxHeight or void
      @updateMaxSize!
      @width = Number env.width ? app.width or 800
      @height = Number env.height ? app.height or 600
      @updateSize!
      @x = Number env.x ? app.x ? (os.desktopWidth - @width) / 2 + @random -32 32
      @y = Number env.y ? app.y ? (os.desktopHeight - @height) / 2 + @random -32 32
      @updateXY!
      @minimized = Boolean env.minimized ? app.minimized ? no
      @maximized = Boolean env.maximized ? app.maximized ? no
      @fullscreen = Boolean env.fullscreen ? app.fullscreen ? no
      @noHeader$ = Boolean env.noHeader ? app.noHeader ? no
      @updateNoHeader!
      @skipTaskbar = Boolean env.skipTaskbar ? app.skipTaskbar ? no
      @autoListen = Boolean env.autoListen ? app.autoListen ? yes
      @supportedExts = app.supportedExts
      @args = env.args ? app.args ? {}
      @perms = @createTaskPerms env.perms ? app.perms

      @closedResolve = void
      @closedPromise = new Promise (@closedResolve) !~>
      @listened = no
      @listenedResolve = void
      @listenedPromise = new Promise (@listenedResolve) !~>
      @moving = no
      @resizeData = void
      @bodyEl = void
      @frameEl = void
      @postMessage = void

      os.tasks.push @

      @focus!

      m.redraw!

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
         try
            styl = await os.readFile "#@path/app.styl"
         styl = importVar stylF
         styl = importVar stylB
         styl = stylus.render styl, compress: yes
         html = importVar htmlF
         html .= replace /<!-- Code injected by live-server -->.+<\/script>/s ""
         frameEl = document.createElement \iframe
         frameEl.className = \Task-frame
         frameEl.sandbox = """
            allow-downloads
            allow-forms
            allow-orientation-lock
            allow-pointer-lock
            allow-scripts
         """
         frameEl.allow = "
            clipboard-read;
         "
         frameEl.srcdoc = html
         @bodyEl.appendChild frameEl
         @frameEl = frameEl

      m.redraw!

   getEntIcon: (ent) ->
      {ext, name, path} = ent
      if ent.isFile
         if name == \app.yml
            dirPath = @dirPath path
            if app = os.apps.find (.path == dirPath)
               app.icon
            else
               \file-dashed-line
         else
            match ext
            | /^(txt|md|log)$/
               \file-lines
            | /^(jsx?|tsx?|ls|coffee|css|styl|s[ac]ss|less|html?|pug|json|csv|xml)$/
               \file-code
            | /^(jpe?g|png|gif|webp|svg|ico|jfif|bmp|heic)$/
               \file-image
            | /^(mp3|aac|wav|mid|flac|ogg)$/
               \file-audio
            | /^(mp4|3gp|webm|avi)$/
               \file-video
            | /^(zip|rar|tar|7z)$/
               \file-zipper
            | /^(pdf)$/
               \file-pdf
            else
               \file
      else
         switch path
         | \/C/images
            \folder-image!f59e0b
         else
            \folder!f59e0b

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
      ent.icon = await @getEntIcon ent
      if children
         ent.children = await Promise.all children.map (@makeEnt <|)
      ent

   getEnt: (path) ->
      ent = await fs.getEntry path
      @makeEnt ent

   castEnt: (path) ->
      if typeof! path == \Object
         path
      else
         @getEnt path

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

   openEnt: (ent, appName) !->
      ent = await @castEnt ent
      if ent.isDir
         os.runTask \FileManager,
            args:
               path: ent.path
      else
         unless appName
            if ext = os.exts.find (.name == ent.ext)
               appName = ext.defaultAppNames.0
         if appName
            pid = os.runTask appName
            await os.waitListenedTask pid
            await os.emitTask pid, \ents [ent]

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
      type = \dataURL if type == \dataUrl
      type = @upperFirst type
      fs.readFile path,
         type: type

   writeFile: (path, data) ->
      path = @castPath path
      file = await fs.writeFile path, data
      @makeEnt file

   deleteFile: (path) ->
      path = @castPath path
      result = await fs.unlink path
      result == void

   installApp: (installType, sourcePath, path, env = {}) !->
      switch installType
      | \boot
         yaml = await m.fetch "#sourcePath/app.yml"
         pack = jsyaml.safeLoad yaml
         app =
            name: pack.name
            path: path
            type: pack.type or \normal
            icon: pack.icon or \square-dashed
            version: pack.version
            author: pack.author
            admin: pack.admin
            focusable: pack.focusable
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
            skipTaskbar: pack.skipTaskbar
            autoListen: pack.autoListen
            supportedExts: @castArr pack.supportedExts
            description: pack.description
            license: pack.license
         app <<<
            pinnedTaskbar: env.pinnedTaskbar ? pack.pinnedTaskbar
            perms: os.createAppPerms app
         code = await m.fetch "#sourcePath/app.ls"
         await os.writeFile "#path/app.ls" code
         try
            styl = await m.fetch "#sourcePath/app.styl"
            await os.writeFile "#path/app.styl" styl
         await os.writeFile "#path/app.yml" yaml
         os.apps.push app
         for extName in app.supportedExts
            @addDefaultAppNameExt extName, app.name
      m.redraw!

   getVapps: ->
      vapps = os.apps.map (app) ~>
         name: app.name
         path: app.path
         type: app.type
         icon: app.icon
         version: app.version
         author: app.author
         description: app.description
      vapps

   createAppPerms: (app) ->
      appPerms =
         *  name: \taskbarView
            status: \ask
         *  name: \taskbarEdit
            status: \ask
         *  name: \desktopBgView
            status: \ask
         *  name: \desktopBgEdit
            status: \ask
         *  name: \entsView
            status: \ask
            paths:
               *  path: app.path
                  status: \granted
               ...
         *  name: \entsEdit
            status: \ask
            paths:
               *  path: app.path
                  status: \granted
               ...
      appPerms

   createTaskPerms: (permsData) ->
      taskPerms = structuredClone @app.perms
      if Array.isArray permsData
         for name in permsData
            if typeof name == \string
               if typeof! name == \Object
                  [name, val] = Object.entries name .0
               if taskPerm = taskPerms.find (.name == name)
                  if name in [\entsView \entsEdit]
                     if taskPerm.status == \denied
                        taskPerm.status = \ask
                     if Array.isArray val
                        taskPerm.val.push ...val
                  else
                     taskPerm.status = \granted
      taskPerms

   requestTaskPerm: (name, val) ->
      if taskPerm = @perms.find (.name == name)
         {status} = taskPerm
         if @admin
            status = \granted
         else
            if status == \ask
               unless taskPerm.promise
                  taskPerm.promise = @askTaskPerm taskPerm
                     .then !~>
                        delete taskPerm.promise
               answer = await taskPerm.promise
               switch answer
               | \always \session
                  status = \granted
               | \denied
                  status = \denied
            taskPerm.status = status
         if status == \granted
            taskPerm.requested = yes
            switch name
            | \taskbarView
               await @permEmit name, \$taskbarPosition os.taskbarPosition
               await @permEmit name, \$taskbarHeight os.taskbarHeight
            | \desktopBgView
               await @permEmit name, \$desktopBgImageDataUrl os.desktopBgImageDataUrl
      else
         throw Error "Quyền không xác định"
      status

   getOrAddExt: (extName) ->
      if /^[a-z\d]+$/.test extName
         ext = os.exts.find (.name == extName)
         unless ext
            ext =
               name: extName
               defaultAppNames: []
            os.exts.push ext
      else
         throw Error "Tên phần mở rộng không hợp lệ"
      ext

   addDefaultAppNameExt: (extName, appName) !->
      ext = @getOrAddExt extName
      app = os.apps.find (.name == appName)
      if app
         unless ext.defaultAppNames.includes appName
            ext.defaultAppNames.push appName
      else
         throw Error "Không tìm thấy ứng dụng '#appName'"

   emit: (evtName, val) ->
      @sendTA evtName, val

   emitAll: (evtName, val) ->
      Promise.all os.tasks.map (task) ~>
         task.emit evtName, val

   permEmit: (permName, propName, val) ->
      perm = @perms.find (.name == permName)
      if perm.requested
         @sendTA propName, val

   permEmitAll: (permName, propName, val) ->
      Promise.all os.tasks.map (task) ~>
         task.permEmit permName, propName, val

   runTask: (name, env) ->
      app = os.apps.find (.name == name)
      if app
         task = new Task app, env
         m.redraw!
      else
         throw Error "Không tìm thấy ứng dụng '#name'"
      task.pid

   getTask: (pid) ->
      os.tasks.find (.pid == pid)

   waitListenedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.listenedPromise

   waitClosedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.closedPromise

   emitTask: (pid, evtName, val) ->
      task = @getTask pid
      task.emit evtName, val

   setTaskbarPosition: (val) !->
      unless os.taskbarPosition == val
         os.taskbarPosition = val
         os.permEmitAll \taskbarView \$taskbarPosition val
      m.redraw!

   setDesktopBgImagePath: (path) !->
      path = @joinPath @path, path
      dataUrl = await os.readFile path, \dataUrl
      os.desktopBgImagePath = path
      os.desktopBgImageDataUrl = dataUrl
      @permEmitAll \desktopBgView \$desktopBgImageDataUrl dataUrl
      m.redraw!

   focus: !->
      if @focusable
         if os.task != @
            @z = os.tasks.length
            @minimize no
            os.updateFocusedTask!
      else
         os.task = void
      m.redraw!

   minimize: (val) !->
      val = Boolean val ? !@minimized
      if val != @minimized
         @minimized = val
         os.updateFocusedTask!
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
         for , resolver of @resolvers
            resolver.resolve!
         if @listenedResolve
            @listenedResolve no
            @listenedResolve = void
         @closedResolve val
         @closedResolve = void
         @listened = no
         index = os.tasks.indexOf @
         os.tasks.splice index, 1
         os.updateFocusedTask!
         m.redraw!

   updateMinSize: !->
      @minWidth = Math.round @clamp @minWidth$, 200 os.desktopWidth
      @minHeight = Math.round @clamp @minHeight$, 80 os.desktopHeight

   updateMaxSize: !->
      @maxWidth = Math.round @clamp @maxWidth$ ? os.desktopWidth, @minWidth, os.desktopWidth
      @maxHeight = Math.round @clamp @maxHeight$ ? os.desktopHeight, @minHeight, os.desktopHeight

   updateSize: !->
      @width = Math.round @clamp @width, @minWidth, @maxWidth
      @height = Math.round @clamp @height, @minHeight, @maxHeight

   updateXY: !->
      @x = Math.floor @clamp @x, 0 os.desktopWidth - @width
      @y = Math.floor @clamp @y, 0 os.desktopHeight - @height

   updateNoHeader: !->
      @noHeader = @noHeader$ or @fullscreen
      m.redraw!

   updateSizeDom: !->
      @dom.style <<< m.style do
         width: @width
         height: @height

   updateXYDom: !->
      @dom.style <<< m.style do
         left: @x
         top: @y

   sendTF: (name, ...args) ->
      if @postMessage
         [mid, promise] = @addResolver!
         @postMessage do
            type: \tf
            mid: mid
            pid: @pid
            name: name
            args: args
            \*
         promise

   sendTA: (name, val) ->
      if @postMessage
         [mid, promise] = @addResolver!
         @postMessage do
            type: \ta
            mid: mid
            pid: @pid
            name: name
            val: val
            \*
         promise

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
      @focus!
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
         @listened = yes
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
      promise = new Promise (resolve2) !~>
         resolve := resolve2
      [close, promise]

   showSubmenuMenu: (rect, items, isAddFrameXY) ->
      [close, promise] = @showMenu rect, items, isAddFrameXY, \OS-submenuMenu,
         placement: \right-start
         offset: [-4 -2]
      os.submenuMenuClose = close
      promise

   closeSubmenuMenu: !->
      if os.submenuMenuClose
         os.submenuMenuClose!
         os.submenuMenuClose = void

   showContextMenu: (x, y, items, isAddFrameXY) ->
      rect = @makeRectFromXY x, y
      [close, promise] = @showMenu rect, items, isAddFrameXY, \OS-contextMenu,
         placement: \bottom-start
         flips: [\top-start]
      os.contextMenuClose = close
      promise

   closeContextMenu: !->
      if os.contextMenuClose
         os.contextMenuClose!
         os.contextMenuClose = void

   showMenubarMenu: (rect, items, isAddFrameXY) ->
      [close, promise] = @showMenu rect, items, isAddFrameXY, \OS-menubarMenu,
         placement: \bottom-start
         flips: [\right-start]
      os.menubarMenuClose = close
      promise

   closeMenubarMenu: !->
      if os.menubarMenuClose
         os.menubarMenuClose!
         os.menubarMenuClose = void

   onpointerdownTitle: (event) !->
      if event.buttons == 1
         event.target.setPointerCapture event.pointerId
         @moving = yes

   onpointermoveTitle: (event) !->
      event.redraw = no
      if @moving
         @x += event.movementX
         @y += event.movementY
         if @maximized
            @x = event.x - @width / 2
            @y = 0
            @updateXY!
            @maximize no
         @updateXYDom!

   onlostpointercaptureTitle: (event) !->
      if event.y < 0
         @maximize yes
      @moving = no
      @updateXY!
      @updateXYDom!

   onclickTitle: (event) !->
      if event.detail % 2 == 0
         @maximize!

   oncontextmenuTitle: (event) !->
      os.addContextMenu event,
         *  text: "Thu nhỏ"
            icon: \minus
            click: !~>
               @minimize!
         *  text: "Phóng to"
            icon: \plus
            click: !~>
               @maximize!
         ,,
         *  text: "Đóng"
            icon: \xmark
            color: \red
            click: !~>
               @close!

   onclickMinimize: (event) !->
      @minimize!

   onclickMaximize: (event) !->
      @maximize!

   onclickClose: (event) !->
      @close!

   onpointerdownResize: (event) !->
      if event.buttons == 1
         event.target.setPointerCapture event.pointerId
         sideX = event.target.dataset.x
         sideY = event.target.dataset.y
         right = @x + @width
         bottom = @y + @height
         @resizeData =
            rect: {@x, @y, @width, @height}
            bound:
               minX: Math.max 0, right - @maxWidth
               minY: Math.max 0, bottom - @maxHeight
               maxX: right - @minWidth
               maxY: bottom - @minHeight
               maxWidth: Math.min @maxWidth, if sideX < 0 => right else os.desktopWidth - @x
               maxHeight: Math.min @maxHeight, if sideY < 0 => bottom else os.desktopHeight - @y
            moveX: 0
            moveY: 0

   onpointermoveResize: (event) !->
      event.redraw = no
      if @resizeData
         sideX = Number event.target.dataset.x
         sideY = Number event.target.dataset.y
         {rect, bound, moveX, moveY} = @resizeData
         if sideX
            moveX += event.movementX
            @width = os.clamp rect.width + moveX * sideX, @minWidth, bound.maxWidth
            if sideX < 0
               @x = os.clamp rect.x + moveX, bound.minX, bound.maxX
            @resizeData.moveX = moveX
         if sideY
            moveY += event.movementY
            @height = os.clamp rect.height + moveY * sideY, @minHeight, bound.maxHeight
            if sideY < 0
               @y = os.clamp rect.y + moveY, bound.minY, bound.maxY
            @resizeData.moveY = moveY
         @updateSizeDom!
         @updateXYDom!

   onlostpointercaptureResize: (event) !->
      @resizeData = void

   view: (vnode, vdom) ->
      m \.Task,
         class: m.class do
            "Task--minimized": @minimized
            "Task--maximized": @maximized
            "Task--fullscreen": @fullscreen
            "Task--noHeader": @noHeader
         style: m.style do
            zIndex: @z
         inert: @minimized
         m \.Task-header,
            inert: @noHeader
            m \.Task-title,
               onpointerdown: @onpointerdownTitle
               onpointermove: @onpointermoveTitle
               onlostpointercapture: @onlostpointercaptureTitle
               onclick: @onclickTitle
               oncontextmenu: @oncontextmenuTitle
               m Icon,
                  class: "mr-2"
                  name: @icon
               m \.Task-titleText,
                  @title
            m \.Task-buttons,
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
         if !@maximized and !@fullscreen
            m \.Task-resizes,
               @@resizeSides.map (side) ~>
                  m \.Task-resize,
                     key: side
                     "data-x": side.0
                     "data-y": side.1
                     onpointerdown: @onpointerdownResize
                     onpointermove: @onpointermoveResize
                     onlostpointercapture: @onlostpointercaptureResize

   @resizeSides =
      [-1 0] [1 0] [0 -1] [0 1]
      [-1 -1] [1 1] [-1 1] [1 -1]
