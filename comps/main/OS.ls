class OS extends Task
   (app, env) ->
      os := @
      osTask := @

      @isOS = yes

      app.perms = @createAppPerms app
      @apps = [app]

      @tasks = []
      @task = void

      @taskbarPositions =
         *  text: "Trên"
            value: \top
         *  text: "Dưới"
            value: \bottom
            isDefault: yes
      @taskbarPosition = \bottom
      @taskbarPositionLocked = no
      @taskbarHeight = 39

      @desktopWidth = void
      @desktopHeight = void
      @desktopTask = void
      @desktopBgImageFits =
         *  text: "Tràn màn hình"
            value: \cover
            isDefault: yes
         *  text: "Vừa màn hình"
            value: \contain
         *  text: "Vừa các cạnh"
            value: \fill
         *  text: "Kích thước gốc"
            value: \none
      @desktopBgImageFit = \cover
      @desktopBgImagePath = void
      @desktopBgImageDataUrl = void
      @updateDesktopSize!

      @time = dayjs!

      @battery = void
      @batteryLevel = void
      @batteryCharging = void
      @batteryChargingTime = void
      @batteryDischargingTime = void

      @brightness = 1

      @nightLight = no

      @fonts =
         *  name: "Arial"
            type: \sans
         *  name: "Segoe UI"
            type: \sans
         *  name: "Roboto"
            type: \sans
         *  name: "Noto Serif"
            type: \serif
         *  name: "D2Coding"
            type: \mono
         *  name: "PragmataPro Mono"
            type: \mono

      @fontSans = "Arial"
      @fontSerif = "Noto Serif"
      @fontMono = "D2Coding"

      @textSize = 16
      @textContrast = 0

      super app, env

      @isTask = no

      @osName = @name
      @osVersion = @version
      @osAuthor = @author

      @submenuMenuClose = void
      @contextMenuClose = void
      @menubarMenuClose = void
      @selectMenuClose = void
      @dropdownMenuClose = void
      @tooltipClose = void
      @tooltipTimeoutId = void

   oncreate: (vnode) !->
      await super vnode

      await @initTime!
      await @initBattery!
      await @initFiles!
      await @initEvents!
      await @initTasks!

      @loaded = yes
      m.redraw!

      @runTask \Settings

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
            path: \/C/desktop
            viewType: \desktop
      @desktopTask = @tasks.find (.pid == pid)
      await @waitListenedTask pid
      m.redraw!

   updateFocusedTask: (isFocusNextTask, isUpdateZ) !->
      prevTask = @task
      tasks = @tasks
      tasks .= toSorted (taskA, taskB) ~>
         taskA.z - taskB.z
      if isUpdateZ
         for task, i in tasks
            task.z = i
         @sendPermTasksAll!
      if isFocusNextTask
         nextTask = tasks.findLast (task) ~>
            task.focusable and !task.minimized
      else
         nextTask = void
      if prevTask != nextTask
         if prevTask and prevTask.isTrayApp
            prevTask.minimize yes
         @task = nextTask
      m.redraw!

   getTaskbarPinnedAppsAndTasks: (isTrayApp, isLeftTrayApp) ->
      isTrayApp = Boolean isTrayApp
      isLeftTrayApp = Boolean isLeftTrayApp
      pinnedApps = @apps
         .filter (app) ~>
            app.pinnedTaskbar
         .map (app) ~>
            task = @tasks.find (task2) ~>
               task2.app == app and !task2.skipTaskbar
            task or app
      tasks = @tasks
         .filter (task) ~>
            !pinnedApps.includes task
      items = pinnedApps
         .concat tasks
         .filter (task) ~>
            task.isTrayApp == isTrayApp and task.isLeftTrayApp == isLeftTrayApp
      items

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
               disabled: @taskbarPositionLocked
               subitems: @taskbarPositions.map (item) ~>
                  text: item.text
                  icon: \circle-small if @taskbarPosition == item.value
                  click: !~>
                     @setTaskbarPosition item.value
            *  text: "Khóa vị trí taskbar"
               icon: \check if @taskbarPositionLocked
               click: !~>
                  @setTaskbarPositionLocked!
            ,,
            *  text: "Trình quản lý tác vụ"
               icon: \fad:rectangle-history
               click: !~>
                  @runTask \TaskManager

   onclickTaskbarTask: (task, event) !->
      if @task == task
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
      for task in @tasks
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
         class: m.class do
            "OS--taskbar-#@taskbarPosition"
            "OS--fullscreen": @task?fullscreen
            "OS Portal"
         style: m.style do
            "--fontSans": @fontSans
            "--fontSerif": @fontSerif
            "--fontMono": @fontMono
            "--textSize": @textSize
            "--textContrast": @textContrast
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
               m \.OS-taskbarHomes,
                  @getTaskbarPinnedAppsAndTasks yes yes .map (item) ~>
                     if item instanceof Task
                        m Button,
                           key: item.pid
                           class: "OS-taskbarTask OS-trayTask OS-leftTrayTask OS-taskbarTask--#{item.pid} OS-stopMouseDown"
                           active: @task == item
                           activeClass: "bg-blue2 text-white"
                           basic: yes
                           icon: item.icon
                           onclick: @onclickTaskbarTask.bind void item
                     else
                        m Button,
                           key: item.path
                           class: "OS-taskbarPinnedApp OS-stopMouseDown"
                           basic: yes
                           icon: item.icon
                           tooltip: "#{item.name}|top,bottom"
                           onclick: @onclickTaskbarPinnedApp.bind void item
               m \.OS-taskbarTasks,
                  @getTaskbarPinnedAppsAndTasks no no .map (item) ~>
                     if item instanceof Task
                        if item.skipTaskbar
                           m \.OS-taskbarTask.OS-taskbarTask--skip,
                              class: "OS-taskbarTask--#{item.pid}"
                              key: item.pid
                        else
                           m Popover,
                              key: item.pid
                              minWidth: 200
                              interactionKind: \contextmenu
                              content: (close) ~>
                                 m Menu,
                                    basic: yes
                                    items:
                                       *  header: item.name
                                       *  text: "Mở tác vụ mới"
                                          icon: item.icon
                                          hidden: item.isOpenSameTask
                                          click: !~>
                                             close!
                                             os.runTask item.name
                                       ,,
                                       *  text: "Bỏ ghim taskbar"
                                          icon: \thumbtack
                                          click: !~>
                                             close!
                                       *  text: "Buộc đóng tác vụ"
                                          icon: \octagon-xmark
                                          color: \red
                                          click: !~>
                                             close!
                                             item.forceClose!
                                       ,,
                                       *  text: "Đóng tác vụ"
                                          icon: \xmark
                                          color: \red
                                          click: !~>
                                             close!
                                             item.close!
                              m Button,
                                 class: "OS-taskbarTask OS-taskbarTask--#{item.pid} OS-stopMouseDown"
                                 active: @task == item
                                 activeClass: "bg-blue2 text-white"
                                 basic: yes
                                 icon: item.icon
                                 onclick: @onclickTaskbarTask.bind void item
                                 item.title
                     else
                        m Popover,
                           key: item.path
                           minWidth: 200
                           interactionKind: \contextmenu
                           content: (close) ~>
                              m Menu,
                                 basic: yes
                                 items:
                                    *  header: item.name
                                    *  text: "Mở ứng dụng"
                                       icon: item.icon
                                       click: !~>
                                          close!
                                          @runTask item.name
                                    ,,
                                    *  text: "Bỏ ghim taskbar"
                                       icon: \thumbtack
                                       click: !~>
                                          close!
                           m Button,
                              class: "OS-taskbarPinnedApp OS-stopMouseDown"
                              basic: yes
                              icon: item.icon
                              tooltip: "#{item.name}|top,bottom"
                              onclick: @onclickTaskbarPinnedApp.bind void item
               m \.OS-taskbarTrays,
                  m Button,
                     basic: yes
                     icon: \wifi
                     tooltip: "Mạng|top,bottom"
                  m Popover,
                     maxWidth: 360
                     content: ~>
                        m \.p-3,
                           "Tính năng này hiện không khả dụng, vì hiện tại chưa có cách nào để kiểm soát âm lượng của một trang web."
                     m Button,
                        basic: yes
                        icon: \volume
                        tooltip: "Âm thanh|top,bottom"
                  if @battery
                     m Button,
                        basic: yes
                        icon: @getBatteryIcon!
                        tooltip: "Pin: #{@batteryLevel * 100}%, #{@batteryCharging and \đang or \không} sạc|top,bottom"
                  m Button,
                     basic: yes
                     tooltip: "#{@upperFirst @time.format "dddd, DD MMMM, YYYY"}|top,bottom"
                     @time.format "HH:mm, DD/MM/YYYY"
                  @getTaskbarPinnedAppsAndTasks yes no .map (item) ~>
                     if item instanceof Task
                        m Button,
                           key: item.pid
                           class: "OS-taskbarTask OS-trayTask OS-rightTrayTask OS-taskbarTask--#{item.pid} OS-stopMouseDown"
                           active: @task == item
                           activeClass: "bg-blue2 text-white"
                           basic: yes
                           icon: item.icon
                           onclick: @onclickTaskbarTask.bind void item
                     else
                        m Button,
                           key: item.path
                           class: "OS-taskbarPinnedApp OS-stopMouseDown"
                           basic: yes
                           icon: item.icon
                           tooltip: "#{item.name}|top,bottom"
                           onclick: @onclickTaskbarPinnedApp.bind void item
            m \.OS-nightLight,
               style:
                  opacity: @nightLight and 1 or 0
            m \.OS-brightness,
               style:
                  opacity: 1 - @brightness
