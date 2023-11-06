class OS extends Task
   (app, env) ->
      os := @

      @isOS = yes

      app.perms = @createAppPerms app
      @apps = [app]

      @tasks = []
      @task = void

      @taskbarPosition = \bottom
      @taskbarHeight = 39

      @desktopWidth = void
      @desktopHeight = void
      @desktopTask = void
      @desktopBgImagePath = void
      @desktopBgImageDataUrl = void
      @updateDesktopSize!

      @time = dayjs!

      @battery = void
      @batteryLevel = void
      @batteryCharging = void
      @batteryChargingTime = void
      @batteryDischargingTime = void

      super app, env

      @isTask = no

      @submenuMenuClose = void
      @contextMenuClose = void
      @menubarMenuClose = void
      @tooltipClose = void
      @tooltipTimerId = void

   oncreate: (vnode) !->
      super vnode

      await @initTime!
      await @initBattery!
      await @initFiles!
      await @initEvents!
      await @initTasks!

      m.redraw!

      # @runTask \PDFViewer

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

   initBattery: !->
      @battery = await navigator.getBattery!
      @battery.onlevelchange = @onlevelchangeBattery
      @battery.onchargingchange = @onchargingchangeBattery
      @battery.onchargingtimechange = @onchargingtimechangeBattery
      @battery.ondischargingtimechange = @ondischargingtimechangeBattery
      @onlevelchangeBattery!
      @onchargingchangeBattery!
      @onchargingtimechangeBattery!
      @ondischargingtimechangeBattery!
      m.redraw!

   initFiles: !->
      await fs.init do
         bytes: 1024 * 1024 * 512
      for path in Paths"/C/{*,!(apps)/**}"
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
      window.addEventListener \mouseover @onmouseoverGlobal
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
      await @waitListenedTask pid
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
            task = os.tasks.find (.app == app)
            task or app
      tasks = os.tasks
         .filter (task) ~>
            !pinnedApps.includes task
      [...pinnedApps, ...tasks]

   onlevelchangeBattery: !->
      @batteryLevel = Number @battery.level.toFixed 2
      m.redraw!

   onchargingchangeBattery: !->
      @batteryCharging = @battery.charging
      m.redraw!

   onchargingtimechangeBattery: !->
      @batteryChargingTime = @battery.chargingTime
      m.redraw!

   ondischargingtimechangeBattery: !->
      @batteryDischargingTime = @battery.dischargingTime
      m.redraw!

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

   onmouseoverGlobal: (event) !->
      if event.isTrusted
         if el = event.target.closest "[tooltip]"
            rect = @getRect el
            text = el.getAttribute \tooltip
            isDark = @checkElIsDark el
            @showTooltip rect, text, isDark, no
         else
            @closeTooltip!

   onmousedownGlobal: (event) !->
      if event.isTrusted
         eventData = event{screenX, screenY, buttons}
         eventData.clientX = -1
         eventData.clientY = -1
         @sendAll \call \mousedownMain eventData
         @closeTooltip!

   onmessageGlobal: (event) !->
      if !event.isTrusted or event.origin != \null or !event.data
         return
      {flow, act, mid, tid, pid, name, vals, result, isErr} = event.data
      switch flow
      | \mfm
         task = @tasks.find (.pid == pid)
         unless task
            return
         task.resolveResolver mid, result, isErr
      | \fmf
         task = @tasks.find (.tid == tid)
         unless task
            return
         isWait = no
         switch act
         | \call
            isCall = yes
            method = task[name]
         | \callWait
            isCall = yes
            isWait = yes
            method = task[name]
         if isCall
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
         if task.postMessage
            task.postMessage do
               flow: flow
               mid: mid
               result: result
               isErr: isErr
               \*

   view: (vnode) ->
      super vnode,
         m \.OS.Portal,
            class: m.class do
               "OS--taskbar-#@taskbarPosition"
               "OS--fullscreen": os.task?fullscreen
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
                  style: m.style do
                     height: @taskbarHeight
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
                           if item.skipTaskbar
                              m \.OS-taskbarTask.OS-taskbarTask--skip,
                                 class: "OS-taskbarTask--#{item.pid}"
                                 key: item.pid
                           else
                              m Popover,
                                 key: item.pid
                                 interactionKind: \contextmenu
                                 content: (close) ~>
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
                                                close!
                                                item.close!
                                 m Button,
                                    class: "OS-taskbarTask OS-taskbarTask--#{item.pid} OS-stopMouseDown"
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
                                 tooltip: "#{item.name}|top"
                                 onclick: @onclickTaskbarPinnedApp.bind void item
                  m \.OS-taskbarTrays,
                     m Button,
                        basic: yes
                        icon: \wifi
                        tooltip: "Mạng|top"
                     m Button,
                        basic: yes
                        icon: \volume
                        tooltip: "Âm thanh|top"
                     if @battery
                        m Button,
                           basic: yes
                           icon: @getBatteryIcon!
                           tooltip: "Pin: #{@batteryLevel * 100}%, #{@batteryCharging and \đang or \không} sạc|top"
                     m Button,
                        basic: yes
                        tooltip: @upperFirst @time.format "dddd, DD MMMM, YYYY|top"
                        @time.format "HH:mm, DD/MM/YYYY"
                     m Button,
                        basic: yes
                        icon: \message
