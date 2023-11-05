class Task extends Both
   (app, env = {}) ->
      super!

      @isMain = yes
      @isTask = yes

      @app = app
      @env = env
      @parentTask = env.parentTask

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
      @isModal = Boolean env.isModal ? app.isModal ? no
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
      @useContentSize = Boolean env.useContentSize ? app.useContentSize ? no
      @noHeader = Boolean env.noHeader ? app.noHeader ? no
      @skipTaskbar = Boolean env.skipTaskbar ? app.skipTaskbar ? no
      @hidden = Boolean env.hidden ? app.hidden ? @useContentSize
      @autoListen = Boolean env.autoListen ? app.autoListen ? yes
      @supportedExts = app.supportedExts
      @openEntsSameTask = Boolean env.openEntsSameTask ? app.openEntsSameTask ? no
      @args = env.args ? app.args ? {}
      @perms = @createTaskPerms env.perms ? app.perms

      @isSandbox = @type !in [\os \core]
      @closed = no
      @closedResolve = void
      @closedPromise = new Promise (@closedResolve) !~>
      @isAskingClose = no
      @listened = no
      @listenedResolve = void
      @listenedPromise = new Promise (@listenedResolve) !~>
      @moving = no
      @resizeData = void
      @isUnmaximized = no
      @minimizeAnim = void
      @bodyEl = void
      @frameEl = void
      @postMessage = void
      @loaded = no

      os.tasks.push @

      unless @minimized
         @focus!

      m.redraw!

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Task-body
      @stylEl = @dom.querySelector \.Task-styl

      @updateSizeDom!
      @updateXYDom!
      @updateMinimizeDom yes if @minimized

      unless @isOS
         switch @type
         | \core
            styl = ""
            try
               styl = await os.readFile "#@path/app.styl"
            styl = stylus.render styl,
               compress: yes
            @stylEl.textContent = styl
            code = await os.readFile "#@path/app.ls"
            code = """
               (App, os) ->
                  #{@indent code, 1 yes}
                  App
            """
            code = livescript.compile code,
               bare: yes
            frameEl = document.createElement \div
            frameEl.className = \Task-frame
            @frameEl = frameEl
            @bodyEl.appendChild frameEl
            comp = (eval code) void @
            m.mount frameEl, comp

         else
            importVar = eval importVarCode
            styl = ""
            try
               styl = await os.readFile "#@path/app.styl"
            styl = importVar stylF
            styl = importVar stylB
            styl = stylus.render styl,
               compress: yes
            code = await os.readFile "#@path/app.ls"
            code = importVar codeF
            code = importVar codeB
            code = livescript.compile code
            html = importVar htmlF
            html .= replace /<!-- Code injected by live-server -->.+<\/script>/s ""
            frameEl = document.createElement \iframe
            frameEl.className = \Task-frame
            @frameEl = frameEl
            @bodyEl.appendChild frameEl
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

      m.redraw!

   getNoHeader: ->
      @noHeader or @fullscreen

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

   getBatteryIcon: ->
      if os.batteryLevel?
         switch
         | os.batteryLevel <= 0.01 => \battery-empty
         | os.batteryLevel <= 0.2 => \battery-low
         | os.batteryLevel <= 0.4 => \battery-quarter
         | os.batteryLevel <= 0.6 => \battery-half
         | os.batteryLevel <= 0.8 => \battery-three-quarters
         else \battery-full
      else \battery-exclamation

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
      if appName
         if app = @getApp appName
            pid = os.runTask app.name
            await os.waitListenedTask pid
            os.emitTask pid, \ents [ent]
      else
         if ent.isDir
            os.runTask \FileManager,
               args:
                  path: ent.path
         else
            if ent.name == \app.yml
               yaml = await os.readFile ent
               pack = jsyaml.safeLoad yaml
               if app = os.apps.find (.name == pack.name)
                  os.runTask app.name
            else
               if app = os.apps.find (.supportedExts.includes ent.ext)
                  pid = os.runTask app.name
                  await os.waitListenedTask pid
                  os.emitTask pid, \ents [ent]
               else
                  os.openWithEnt ent

   openWithEnt: (ent) !->
      if app = await @pickOpenWithVappByEnt ent
         @openEnt ent, app.name

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
            useContentSize: pack.useContentSize
            noHeader: pack.noHeader
            skipTaskbar: pack.skipTaskbar
            isModal: pack.isModal
            hidden: pack.hidden
            autoListen: pack.autoListen
            supportedExts: @castArr pack.supportedExts
            openEntsSameTask: pack.openEntsSameTask
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
         vapps = @getVapps!
         @permEmitAll \appsView \$apps vapps
      m.redraw!

   getVapps: ->
      vapps = os.apps.map (app) ~>
         @makeVapp app
      vapps

   makeVapp: (app) ->
      name: app.name
      path: app.path
      type: app.type
      icon: app.icon
      version: app.version
      author: app.author
      supportedExts: app.supportedExts
      description: app.description

   getApp: (appName) ->
      os.apps.find (.name == appName)

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
         *  name: \appsView
            status: \ask
         *  name: \tasksView
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
                        taskPerm.paths.push val.map (path) ~>
                           path: path
                           status: \granted
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
            | \appsView
               vapps = @getVapps!
               await @permEmit name, \$apps vapps
      else
         throw Error "Quyền không xác định"
      status

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

   eventEmit: (eventName, val) ->
      @sendTA eventName, val

   runTask: (name, env = {}) ->
      env.parentTask ?= @
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
      if task = @getTask pid
         task.emit evtName, val

   closeTask: (pid, val) !->
      if task = @getTask pid
         await task.close val

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

   focus: (skipFocusModals) !->
      if @focusable
         if os.task != @
            if @isModal and @parentTask
               @parentTask.focus yes
            @z = os.tasks.length
            @minimize no
            os.updateFocusedTask!
            @focusModals! unless skipFocusModals
      else
         os.task = void
         @focusModals! unless skipFocusModals
      m.redraw!

   focusModals: !->
      modal = os.tasks.find (task) ~>
         task.isModal and task.parentTask == @
      if modal
         modal.focus!
      m.redraw!

   minimize: (val) !->
      val = Boolean val ? !@minimized
      if val != @minimized
         @minimized = val
         os.updateFocusedTask!
         @updateMinimizeDom!
         m.redraw!

   maximize: (val) !->
      val = Boolean val ? !@maximized
      if val != @maximized
         @maximized = val
         @isUnmaximized = !val
         m.redraw!

   setFullscreen: (val) !->
      val = Boolean val ? !@fullscreen
      if val != @fullscreen
         @fullscreen = val
         m.redraw!

   fitContentSize: (width, height) !->
      @dom.classList.add \Task--useContentSize
      unless @isSandbox
         {width, height} = @frameEl.getBoundingClientRect!
      width = Math.ceil width
      height = Math.ceil height
      @dom.classList.remove \Task--useContentSize
      width += 8
      height += 8
      unless @getNoHeader!
         height += 28
      @x += (@width - width) / 2
      @y += (@height - height) / 2
      @width = width
      @height = height
      @updateSize!
      @updateXY!
      @updateSizeDom!
      @updateXYDom!
      @show!
      m.redraw!

   show: !->
      if @hidden
         @hidden = no
         if @loaded == 0
            @loaded = yes
         m.redraw!

   alert: (message, opts) ->
      opts = @castNewObj opts
      pid = os.runTask \Popup,
         width: opts.width
         height: opts.height
         maxHeight: opts.height or opts.maxHeight
         args:
            type: \alert
            message: message
            opts: opts
         parentTask: @
      os.waitClosedTask pid

   confirm: (message, opts) ->
      opts = @castNewObj opts, \cancelable
      !!= opts.cancelable
      pid = os.runTask \Popup,
         width: opts.width
         height: opts.height
         maxHeight: opts.height or opts.maxHeight
         args:
            type: \confirm
            message: message
            opts: opts
         parentTask: @
      result = await os.waitClosedTask pid
      unless opts.cancelable
         result = Boolean result
      result

   prompt: (message, opts) ->
      opts = @castNewObj opts, \defaultValue
      pid = os.runTask \Popup,
         width: opts.width
         height: opts.height
         maxHeight: opts.height or opts.maxHeight
         args:
            type: \prompt
            message: message
            opts: opts
         parentTask: @
      os.waitClosedTask pid

   pickOpenWithVappByEnt: (ent) ->
      pid = os.runTask \OpenWith,
         args:
            ent: ent
         parentTask: @
      os.waitClosedTask pid

   close: (val) !->
      if !@closed and !@isAskingClose
         @isAskingClose = yes
         m.redraw!
         isClose = await @eventEmit \$$close
         @isAskingClose = no
         unless isClose == no
            @listened = no
            @postMessage = void
            @closed = yes
            for , resolver of @resolvers
               resolver.resolve!
            if @listenedResolve
               @listenedResolve no
               @listenedResolve = void
            @closedResolve val
            @closedResolve = void
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

   updateSizeDom: !->
      @dom?style <<< m.style do
         width: @width
         height: @height

   updateXYDom: !->
      @dom?style <<< m.style do
         left: @x
         top: @y

   updateMinimizeDom: (isFirst) !->
      el = document.querySelector ".OS-taskbarTask--#@pid"
      {x, y, width, height} = el.getBoundingClientRect!
      x += Math.floor (width - 200) / 2
      width = 200
      if os.taskbarPosition == \top
         y -= os.taskbarHeight
      if @minimized
         keyframe =
            left: x
            top: y
            width: width
            height: height
            borderRadius: 6
      else
         if @maximized
            keyframe =
               left: 0
               top: 0
               width: \100%
               height: \100%
               borderRadius: 0
         else
            keyframe =
               left: @x
               top: @y
               width: @width
               height: @height
               borderRadius: 6
      anim = @dom.animate do
         *  m.style keyframe
         *  duration: 500
            easing: "cubic-bezier(.22, 1, .36, 1)"
            fill: \forwards if @minimized
      @dom.hidden = isFirst
      if @minimized
         @minimizeAnim = anim
      else
         @minimizeAnim?reverse!
         @minimizeAnim = void

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
      useContentSize: @useContentSize
      autoListen: @autoListen
      args: @args

   loadedFrme: !->
      if @hidden
         @loaded = 0
      else
         @loaded = yes
      m.redraw!

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
      popper = @createPopper targetEl, popperEl, popperOpts
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
      @closeContextMenu!
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

   showTooltip: (rect, text, isAddFrameXY) !->
      @closeTooltip!
      @tooltipTimerId = setTimeout !~>
         vals = @formatTooltip text
         text := vals.0
         placements = vals.1
         if isAddFrameXY
            @addRectXYByFrameEl rect
         targetEl =
            getBoundingClientRect: ~>
               rect
         popperEl = document.createElement \div
         popperEl.className = "OS-tooltip"
         portalEl = os.dom
         portalEl.appendChild popperEl
         m.render popperEl, text
         popper = @createPopper targetEl, popperEl,
            placement: placements.0
            offset: [0 3]
            flips: placements.slice 1
         os.tooltipClose = !~>
            if popper
               m.render popperEl
               popperEl.remove!
               popper.destroy!
               popper := void
      , 200

   closeTooltip: !->
      clearTimeout @tooltipTimerId
      if os.tooltipClose
         os.tooltipClose!
         os.tooltipClose = void

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
      if event.y <= 0
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

   onbeforeremove: ->
      anim = @dom.animate do
         *  scale: 0.9
            opacity: 0
         *  duration: 500
            easing: "cubic-bezier(.22, 1, .36, 1)"
      anim.finished

   view: (vnode, vdom) ->
      m \.Task,
         class: m.class do
            "Task--shown": !@hidden
            "Task--minimized": @minimized
            "Task--maximized": @maximized
            "Task--unmaximized": @isUnmaximized
            "Task--fullscreen": @fullscreen
            "Task--noHeader": @getNoHeader!
         style: m.style do
            zIndex: @z
         inert: @closed or @minimized
         m \.Task-header,
            inert: @getNoHeader!
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
         m \style.Task-styl
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
