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
      @width = Number env.width ? app.width or 900
      @height = Number env.height ? app.height or 640
      @updateSize!
      @x = Number env.x ? app.x ? (os.desktopWidth - @width) / 2 + @random -32 32
      @y = Number env.y ? app.y ? (os.desktopHeight - @height) / 2 + @random -32 32
      @updateXY!
      @minimized = Boolean env.minimized ? app.minimized ? no
      @maximized = Boolean env.maximized ? app.maximized ? no
      @fullscreen = Boolean env.fullscreen ? app.fullscreen ? no
      @useContentSize = Boolean env.useContentSize ? app.useContentSize ? no
      @darkMode = Boolean env.darkMode ? app.darkMode ? no
      @noHeader = Boolean env.noHeader ? app.noHeader ? no
      @skipTaskbar = Boolean env.skipTaskbar ? app.skipTaskbar ? no
      @hidden = Boolean env.hidden ? app.hidden ? @useContentSize
      @autoListen = Boolean env.autoListen ? app.autoListen ? yes
      @supportedExts = app.supportedExts
      @isOpenSameTask = Boolean app.isOpenSameTask ? no
      @args = @castNewObj env.args ? app.args
      @perms = @createTaskPerms!

      @isSandbox = @type !in [\os \core]
      @isAskingClose = no
      @closed = no
      @closedResolve = void
      @closedPromise = new Promise (@closedResolve) !~>
      @listened = no
      @listenedResolve = void
      @listenedPromise = new Promise (@listenedResolve) !~>
      @z = 0
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

      @sendPermTasksAll!

      m.redraw!

   oncreate: (vnode) !->
      super vnode

      @bodyEl = @dom.querySelector \.Task-body
      @stylEl = @dom.querySelector \.Task-styl

      @updateSizeDom!
      @updateXYDom!
      @updateMinimizeDom yes if @minimized

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
         @bodyEl.prepend frameEl
         comp = (eval code) void @
         m.mount frameEl, comp
         @loaded = yes

      | \normal
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
         @frameEl = frameEl
         @bodyEl.prepend frameEl

      m.redraw!

   getNoHeader: ->
      @noHeader or @fullscreen

   getEntIcon: (ent) ->
      if ent.isShortcut
         try
            ent = await os.resolveShortcut ent
            @getEntIcon ent
         catch
            \file-exclamation
      else if ent.isFile
         if ent.name == \app.yml
            dirname = @dirPath ent.path
            if app = os.apps.find (.path == dirname)
               app.icon
            else
               \file-dashed-line
         else
            match ent.ext
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
            | /^(gb)$/
               \file-binary
            | /^(pdf)$/
               \file-pdf
            else
               \file
      else
         switch ent.path
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
         ent.isShortcut = ent.ext == \lnk
      else
         ent.isShortcut = no
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
      ent = await os.resolveShortcut ent
      if appName
         if app = @getApp appName
            pid = os.runTask app.name
            await os.waitListenedTask pid
            os.sendTask pid, \emit \ents [ent]
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
                  os.sendTask pid, \emit \ents [ent]
               else
                  os.openWithEnt ent

   openWithEnt: (ent) !->
      if app = await @pickOpenWithVappByEnt ent
         await @openEnt ent, app.name

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

   makeShortcut: (data) ->
      data = @castNewObj data, \targetPath
      shortcut =
         targetPath: String data.targetPath
      shortcut.icon and= String data.icon ? ""
      shortcut

   parseShortcut: (text) ->
      data = jsyaml.safeLoad text
      @makeShortcut data

   dumpShortcut: (shortcut) ->
      jsyaml.safeDump shortcut

   createShortcut: (path, data) ->
      ext = @extPath path
      unless ext == \lnk
         path = "#path.lnk"
      shortcut = @makeShortcut data
      text = @dumpShortcut shortcut
      ent = await @writeFile path, text
      ent

   resolveShortcut: (path, count) ->
      count = Number count ? 16
      count = 16 if isNaN count or count > 16
      if count <= 0
         throw Error "Shortcut quá nhiều cấp lồng nhau"
      ent = await @castEnt path
      if ent.isShortcut
         text = await @readFile ent
         shortcut = await @parseShortcut text
         ent = await @resolveShortcut shortcut.targetPath, count - 1
      ent

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
            darkMode: pack.darkMode
            noHeader: pack.noHeader
            skipTaskbar: pack.skipTaskbar
            isModal: pack.isModal
            hidden: pack.hidden
            autoListen: pack.autoListen
            supportedExts: @castArr pack.supportedExts
            isOpenSameTask: pack.isOpenSameTask
            description: pack.description
            license: pack.license
         app <<<
            pinnedTaskbar: env.pinnedTaskbar ? pack.pinnedTaskbar
            isCreateShortcut: env.isCreateShortcut ? pack.isCreateShortcut ? yes
            perms: os.createAppPerms app
         code = await m.fetch "#sourcePath/app.ls"
         await os.writeFile "#path/app.ls" code
         try
            styl = await m.fetch "#sourcePath/app.styl"
            await os.writeFile "#path/app.styl" styl
         await os.writeFile "#path/app.yml" yaml
         if app.isCreateShortcut
            await os.createShortcut "/C/desktop/#{app.name}.lnk" "#path/app.yml"
         os.apps.push app
         @sendPermAppsAll!
      m.redraw!

   getApp: (appName) ->
      os.apps.find (.name == appName)

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
         *  name: \actionsView
            status: \granted
            listened: yes
         *  name: \fullscreenView
            status: \granted
            listened: yes
         *  name: \darkModeView
            status: \granted
            listened: yes
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

   createTaskPerms: ->
      taskPerms = structuredClone @app.perms
      taskPerms

   requestPerm: (name, val) ->
      if perm = @perms.find (.name == name)
         {status} = perm
         if @admin
            status = \granted
         else
            if status == \ask
               unless perm.promise
                  perm.promise = @askTaskPerm perm
                     .then !~>
                        delete perm.promise
               answer = await perm.promise
               switch answer
               | \always \session
                  status = \granted
               | \denied
                  status = \denied
            perm.status = status
         if status == \granted
            perm.listened = yes
            unless perm.inited
               perm.inited = yes
               switch name
               | \taskbarView
                  await @promiseAll do
                     @send \perm \taskbarPositions os.taskbarPositions
                     @send \perm \taskbarPosition os.taskbarPosition
                     @send \perm \taskbarHeight os.taskbarHeight
               | \desktopBgView
                  await @promiseAll do
                     @send \perm \desktopBgImageFits os.desktopBgImageFits
                     @send \perm \desktopBgImageFit os.desktopBgImageFit
                     @send \perm \desktopBgImagePath os.desktopBgImagePath
                     @send \perm \desktopBgImageDataUrl os.desktopBgImageDataUrl
               | \appsView
                  vapps = @getVapps!
                  await @send \perm \apps vapps
               | \tasksView
                  vtasks = @getVtasks!
                  await @send \perm \tasks vtasks
               | \actionsView
                  await @promiseAll do
                     @send \perm \minimized @minimized
                     @send \perm \maximized @maximized
               | \fullscreenView
                  await @send \perm \fullscreen @fullscreen
               | \darkModeView
                  await @send \perm \darkMode @darkMode
      else
         throw Error "Tên quyền '#name' không hợp lệ"
      status

   send: (act, name, ...vals) ->
      if @postMessage and !@closed
         [mid, promise] = @addResolver!
         @postMessage do
            flow: \mfm
            act: act
            mid: mid
            pid: @pid
            name: name
            vals: vals
            \*
         promise

   sendAll: (act, name, ...vals) ->
      Promise.allSettled os.tasks.map (task) ~>
         task.send act, name, ...vals

   sendPerm: (permName, name, val) ->
      perm = @perms.find (.name == permName)
      if perm.listened
         @send \perm name, val

   sendPermAll: (permName, name, val) ->
      Promise.allSettled os.tasks.map (task) ~>
         task.sendPerm permName, name, val

   sendPermAppsAll: ->
      vapps = @getVapps!
      @sendPermAll \appsView \apps vapps

   sendPermTasksAll: ->
      vtasks = @getVtasks!
      @sendPermAll \tasksView \tasks vtasks

   runTask: (name, env = {}) ->
      app = os.apps.find (.name == name)
      unless app
         ent = @resolveShortcut name
         if ent.isDir
            throw Error "Đường dẫn '#name' là thư mục"
         if ent.name != \app.yml
            throw Error "Đường dẫn '#name' không phải là tập tin app.yml"
         path = @dirPath ent.path
         app = os.apps.find (.path == path)
         unless app
            throw Error "Không tìm thấy ứng dụng với đường dẫn '#name'"
      unless app
         throw Error "Không tìm thấy ứng dụng '#name'"
      env.parentTask ?= @
      env.isOpenSameTask = Boolean env.isOpenSameTask ? app.isOpenSameTask
      if app.isOpenSameTask and env.isOpenSameTask
         if task = os.tasks.find (.app == app)
            task.focus!
      task ?= new Task app, env
      m.redraw!
      task.pid

   getTask: (pid) ->
      os.tasks.find (.pid == pid)

   getVtasks: ->
      vtasks = os.tasks.map (task) ~>
         @makeVtask task
      vtasks

   makeVtask: (task) ->
      name: task.name
      path: task.path
      type: task.type
      icon: task.icon
      author: task.author
      pid: task.pid
      admin: task.admin
      title: task.title
      isModal: task.isModal
      focusable: task.focusable
      minimized: task.minimized
      maximized: task.maximized
      fullscreen: task.fullscreen
      skipTaskbar: task.skipTaskbar
      hidden: task.hidden
      autoListen: task.autoListen
      supportedExts: task.supportedExts
      isOpenSameTask: task.isOpenSameTask
      pinnedTaskbar: task.pinnedTaskbar
      isCreateShortcut: task.isCreateShortcut
      args: task.args
      isAskingClose: task.isAskingClose
      closed: task.closed
      listened: task.listened
      z: task.z

   waitListenedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.listenedPromise

   waitClosedTask: (pid) ->
      if task = os.tasks.find (.pid == pid)
         task.closedPromise

   sendTask: (pid, act, name, ...vals) ->
      if task = @getTask pid
         task.send act, name, ...vals

   focusTask: (pid) !->
      if task = @getTask pid
         await task.focus!

   closeTask: (pid, val) !->
      if task = @getTask pid
         await task.close val

   setTaskbarPosition: (val) !->
      if os.taskbarPosition == val
         return
      unless os.taskbarPositions.some (.value == val)
         throw TypeError "Giá trị taskbarPosition '#val' không hợp lệ"
      os.taskbarPosition = val
      @sendPermAll \taskbarView \taskbarPosition val
      m.redraw!

   setDesktopBgImageFit: (val) !->
      if os.desktopBgImageFit == val
         return
      unless os.desktopBgImageFits.some (.value == val)
         throw TypeError "Giá trị desktopBgImageFit '#val' không hợp lệ"
      os.desktopBgImageFit = val
      @sendPermAll \desktopBgView \desktopBgImageFit val
      m.redraw!

   setDesktopBgImagePath: (path) !->
      path = @joinPath @path, path
      dataUrl = await os.readFile path, \dataUrl
      os.desktopBgImagePath = path
      os.desktopBgImageDataUrl = dataUrl
      @sendPermAll \desktopBgView \desktopBgImagePath path
      @sendPermAll \desktopBgView \desktopBgImageDataUrl dataUrl
      m.redraw!

   focus: (skipFocusModals) !->
      if @focusable
         if os.task != @
            if @isModal and @parentTask
               @parentTask.focus yes
            @z = os.tasks.length
            @sendPermTasksAll!
            @minimize no
            os.updateFocusedTask yes
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
         @sendPerm \actionsView \minimized val
         @sendPermTasksAll!
         os.updateFocusedTask!
         @updateMinimizeDom!
         m.redraw!

   maximize: (val) !->
      val = Boolean val ? !@maximized
      if val != @maximized
         @maximized = val
         @isUnmaximized = !val
         @sendPerm \actionsView \maximized val
         @sendPermTasksAll!
         m.redraw!

   setFullscreen: (val) !->
      val = Boolean val ? !@fullscreen
      if val != @fullscreen
         @fullscreen = val
         @sendPerm \fullscreenView \fullscreen val
         @sendPermTasksAll!
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

   setDarkMode: (val) !->
      val = Boolean val ? !@darkMode
      if val != @darkMode
         @darkMode = val
         @sendPerm \darkModeView \darkMode val
         m.redraw!

   show: !->
      if @hidden
         @hidden = no
         @sendPermTasksAll!
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
         @sendPermTasksAll!
         m.redraw!
         isClose = await @send \ask \close
         unless isClose == no
            @send \call \closeFrme
            @closed = yes
            @listened = no
            @postMessage = void
            for , resolver of @resolvers
               resolver.resolve!
            if @listenedResolve
               @listenedResolve no
               @listenedResolve = void
            @closedResolve val
            @closedResolve = void
            index = os.tasks.indexOf @
            os.tasks.splice index, 1
            @sendPermTasksAll!
            os.updateFocusedTask!
         @isAskingClose = no
         @sendPermTasksAll!
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
            borderRadius: 8
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
               borderRadius: 8
      anim = @dom.animate do
         *  m.style keyframe
         *  duration: 500
            easing: @easeOut
            fill: \forwards if @minimized
      @dom.hidden = isFirst
      if @minimized
         @minimizeAnim = anim
      else
         @minimizeAnim?reverse!
         @minimizeAnim = void

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
      minimized: @minimized
      maximized: @maximized
      fullscreen: @fullscreen
      useContentSize: @useContentSize
      darkMode: @darkMode
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
            task.send \call \mousedownMain eventData

   startListen: (val) !->
      if @listenedResolve
         val ?= yes
         @listened = yes
         @listenedResolve val
         @listenedResolve = void
         @sendPermTasksAll!

   showMenu: (rect, items, hasValueAttr, value, isAddFrameXY, popperClassName, popperOpts) ->
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
               activeItemClass: "bg-blue2 text-white"
               basic: yes
               isSubmenu: yes
               value: if hasValueAttr => value else m.DELETE
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

   showSubmenuMenu: (rect, items, hasValueAttr, value, isAddFrameXY) ->
      [close, promise] = @showMenu rect, items, hasValueAttr, value, isAddFrameXY, \OS-submenuMenu,
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
      [close, promise] = @showMenu rect, items,,, isAddFrameXY, \OS-contextMenu,
         placement: \bottom-start
         flips: [\top-start]
      os.contextMenuClose = close
      promise

   closeContextMenu: !->
      if os.contextMenuClose
         os.contextMenuClose!
         os.contextMenuClose = void

   showMenubarMenu: (rect, items, isAddFrameXY) ->
      [close, promise] = @showMenu rect, items,,, isAddFrameXY, \OS-menubarMenu,
         placement: \bottom-start
         flips: [\right-start]
      os.menubarMenuClose = close
      promise

   closeMenubarMenu: !->
      if os.menubarMenuClose
         os.menubarMenuClose!
         os.menubarMenuClose = void

   showSelectMenu: (rect, items, value, isAddFrameXY) ->
      [close, promise] = @showMenu rect, items, yes value, isAddFrameXY, \OS-selectMenu,
         placement: \bottom
         flips: [\top]
      os.selectMenuClose = close
      promise

   closeSelectMenu: !->
      if os.selectMenuClose
         os.selectMenuClose!
         os.selectMenuClose = void

   showTooltip: (rect, text, isDark, isAddFrameXY) !->
      if text.trim!
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
            popperEl.className = m.class do
               "OS-tooltip--light": isDark
               "OS-tooltip"
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
      @dom.classList.add \Task--closed
      @dom.inert = yes
      anim = @dom.animate do
         *  scale: 0.9
            opacity: 0
         *  duration: 500
            easing: @easeOut
      anim.finished

   view: (vnode, vdom) ->
      m \.Task,
         class: m.class do
            "dark": @darkMode
            "Task--shown": !@hidden
            "Task--minimized": @minimized
            "Task--maximized": @maximized
            "Task--unmaximized": @isUnmaximized
            "Task--fullscreen": @fullscreen
            "Task--noHeader": @getNoHeader!
            "Task--loading": !@loaded
         style: m.style do
            zIndex: @z
         inert: @minimized
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
            unless @loaded
               m \.Task-loading,
                  m Icon,
                     class: "Task-loadingIcon"
                     name: @icon
                     size: 64
                  m \div,
                     @name
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
