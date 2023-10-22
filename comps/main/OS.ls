class OS extends Task
   (app, env) ->
      os := @

      @isOS = yes

      app.perms = @createAppPerms app
      @apps = [app]

      @tasks = []
      @task = void

      @exts = []

      @taskbarPosition = \bottom
      @taskbarHeight = 39

      @desktopWidth = void
      @desktopHeight = void
      @desktopTask = void
      @desktopBgImagePath = void
      @desktopBgImageDataUrl = void
      @updateDesktopSize!

      @time = dayjs!

      super app, env

      @isTask = no

      @submenuMenuClose = void
      @contextMenuClose = void
      @menubarMenuClose = void

   oncreate: (vnode) !->
      super vnode

      await @initTime!
      await @initFiles!
      await @initEvents!
      await @initTasks!

      m.redraw!

      await @runTask \Test

   updateDesktopSize: !->
      @desktopWidth = innerWidth
      @desktopHeight = innerHeight - @taskbarHeight
      m.redraw!

   updateTime: !->
      @time = dayjs!
      m.redraw!

   initTime: !->
      @updateTime!
      setTimeout !~>
         @updateTime!
         setInterval @updateTime, 1000
      , (500 - @time.millisecond!) %% 1000
      m.redraw!

   initFiles: !->
      await fs.init do
         bytes: 1024 * 1024 * 512
      for path in Paths"/C/!(apps)/**"
         if path.includes \.
            buf = await m.fetch path, \arrayBuffer
            await @writeFile path, buf
         else
            await @createDir path
      for path in Paths"/C/apps/*"
         await @installApp \boot path, path
      m.redraw!

   initEvents: !->
      window.addEventListener \resize @onresizeGlobal
      window.addEventListener \mousedown @onmousedownGlobal
      window.addEventListener \message @onmessageGlobal
      m.redraw!

   initTasks: !->
      await @setDesktopBgImagePath \/C/images/background/gradient-blue-pink.jpg
      pid = @runTask \FileManager,
         title: "Desktop"
         focusable: no
         fullscreen: yes
         skipTaskbar: yes
         args:
            isDesktop: yes
            viewType: \desktop
      @desktopTask = @tasks.find (.pid == pid)
      m.redraw!

   updateFocusedTask: !->
      tasks = os.tasks.toSorted (taskA, taskB) ~>
         taskA.z - taskB.z
      for task, i in tasks
         task.z = i
      @task = tasks.findLast (task) ~>
         task.focusable and !task.minimized
      m.redraw!

   getTaskbarPinnedAppsAndTasks: ->
      pinnedApps = os.apps
         .filter (app) ~>
            app.pinnedTaskbar and !app.skipTaskbar
         .map (app) ~>
            task = os.tasks.find (task2) ~>
               task2.app == app and !task2.skipTaskbar
            task or app
      tasks = os.tasks
         .filter (task) ~>
            !task.skipTaskbar and !pinnedApps.includes task
      [...pinnedApps, ...tasks]

   oncontextmenuTaskbar: (event) !->
      if event.target == event.currentTarget
         @addContextMenu event,
            *  text: "Vị trí taskbar"
               icon: \arrows-up-down-left-right
               subitems:
                  *  text: "Trên"
                     icon: \circle-small if @taskbarPosition == \top
                     click: !~>
                        @setTaskbarPosition \top
                  *  text: "Dưới"
                     icon: \circle-small if @taskbarPosition == \bottom
                     click: !~>
                        @setTaskbarPosition \bottom
            *  text: "Khóa vị trí taskbar"
            ,,
            *  text: "Trình quản lý tác vụ"
               icon: \fad:rectangle-history

   onclickTaskbarTask: (task, event) !->
      if os.task == task
         task.minimize!
      else
         task.focus!

   onclickTaskbarPinnedApp: (app, event) !->
      @runTask app.name

   onmousedownOS: (event) !->
      for task in os.tasks
         if task.isTask and task.dom?contains event.target
            task.focus!
            return
      unless event.target.closest \.OS-stopMouseDown
         @focus!

   onresizeGlobal: (event) !->
      @updateDesktopSize!
      for task in os.tasks
         task.updateMinSize!
         task.updateMaxSize!
         task.updateSize!
         task.updateXY!
         task.updateSizeDom!
         task.updateXYDom!
      m.redraw!

   onmousedownGlobal: (event) !->
      if event.isTrusted
         eventData = event{screenX, screenY, buttons}
         eventData.clientX = -1
         eventData.clientY = -1
         for task in @tasks
            task.sendTF \mousedownMain eventData

   onmessageGlobal: (event) !->
      if data = event.data
         {type} = data
         switch type
         | \ftf
            {mid, tid, name, args} = data
            if task = @tasks.find (.tid == tid)
               method = task[name]
               [result, isErr] = await @safeAsyncApply method, args
               task.postMessage do
                  type: \ftf
                  mid: mid
                  result: result
                  isErr: isErr
                  \*
         | \tf \ta
            {mid, pid, result, isErr} = data
            if task = @tasks.find (.pid == pid)
               if resolver = task.resolvers[mid]
                  delete task.resolvers[mid]
                  methodName = isErr and \reject or \resolve
                  resolver[methodName] result
                  m.redraw!

   view: (vnode) ->
      super vnode,
         m \.OS.Portal,
            class: m.class do
               "OS--taskbar-#@taskbarPosition"
            onmousedown: @onmousedownOS
            m \.OS-body,
               m \.OS-tasks,
                  @tasks.map (task) ~>
                     if task.isOS
                        m.fragment do
                           key: task.pid
                     else
                        m task,
                           key: task.pid
               m \.OS-taskbar,
                  oncontextmenu: @oncontextmenuTaskbar
                  m \.OS-taskbarHome,
                     m Button,
                        basic: yes
                        icon: \fad:home
                  m \.OS-taskbarSearch,
                     m TextInput,
                        icon: \search
                        placeholder: "Tìm kiếm"
                  m \.OS-taskbarTasks,
                     @getTaskbarPinnedAppsAndTasks!map (item) ~>
                        if item instanceof Task
                           m Popover,
                              key: item.pid
                              interactionKind: \contextmenu
                              content: ~>
                                 m Menu,
                                    style:
                                       width: 200
                                    basic: yes
                                    items:
                                       *  header: item.name
                                       *  text: "Đóng"
                                          icon: \xmark
                                          color: \red
                                          click: !~>
                                             item.close!
                              m Button,
                                 class: "OS-taskbarTask OS-stopMouseDown"
                                 active: @task == item
                                 basic: yes
                                 icon: item.icon
                                 onclick: @onclickTaskbarTask.bind void item
                                 item.title
                        else
                           m Popover,
                              key: item.path
                              interactionKind: \contextmenu
                              content: (close) ~>
                                 m Menu,
                                    style:
                                       width: 200
                                    basic: yes
                                    items:
                                       *  header: item.name
                                       *  text: "Mở"
                                          click: !~>
                                             close!
                                             @runTask item.name
                                       ,,
                                       *  text: "Bỏ ghim"
                                          icon: \thumbtack
                                          click: !~>
                                             close!
                              m Button,
                                 class: "OS-taskbarPinnedApp OS-stopMouseDown"
                                 basic: yes
                                 icon: item.icon
                                 onclick: @onclickTaskbarPinnedApp.bind void item
                  m \.OS-taskbarTrays,
                     m Button,
                        basic: yes
                        icon: \wifi
                     m Button,
                        basic: yes
                        icon: \volume
                     m Button,
                        basic: yes
                        icon: \battery
                     m Button,
                        basic: yes
                        @time.format "HH:mm DD/MM/YYYY"
                     m Button,
                        basic: yes
                        icon: \message
