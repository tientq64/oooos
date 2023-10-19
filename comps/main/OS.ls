class OS extends Task
   (app, env) ->
      os := @

      @isOS = yes

      app.perms = @createAppPerms app

      @apps = [app]
      @tasks = []

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

   oncreate: (vnode) !->
      super vnode

      await @initTime!
      await @initFiles!
      await @initEvents!
      await @initTasks!

      m.redraw!

      # await @runTask \Test

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
      await @setDesktopBgImagePath \/C/images/background/gradient.jpg
      pid = @runTask \FileManager,
         title: "Desktop"
         fullscreen: yes
         args:
            isDesktop: yes
            viewType: \desktop
      @desktopTask = @tasks.find (.pid == pid)
      m.redraw!

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
               try
                  method = task[name]
                  result = await method.apply void args
               catch
                  result = e
                  isErr = yes
               task.postMessage do
                  type: \ftf
                  mid: mid
                  result: result
                  isErr: isErr
                  \*
         | \tf \ta
            {mid, pid} = data
            if task = @tasks.find (.pid == pid)
               if resolver = task.resolvers[mid]
                  delete task.resolvers[mid]
                  resolver.resolve!
                  m.redraw!

   view: (vnode) ->
      super vnode,
         m \.OS.Portal,
            m \.OS-tasks,
               @tasks.map (task) ~>
                  if task.type != \os
                     m task,
                        key: task.pid
                  else
                     m.fragment do
                        key: task.pid
            m \.OS-taskbar,
               m \.OS-taskbarHome,
                  m Button,
                     basic: yes
                     icon: \fad:home
               m \.OS-taskbarSearch,
                  m TextInput,
                     icon: \search
                     placeholder: "Tìm kiếm"
               m \.OS-taskbarTasks,
                  @tasks.map (task) ~>
                     m Popover,
                        key: task.pid
                        interactionKind: \contextmenu
                        content: ~>
                           m Menu,
                              style:
                                 width: 200
                              basic: yes
                              items:
                                 *  header: task.name
                                 *  text: "Đóng"
                                    icon: \xmark
                                    color: \red
                                    click: !~>
                                       task.close!
                        m Button,
                           class: "OS-taskbarTask"
                           basic: yes
                           icon: task.icon
                           task.title
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
