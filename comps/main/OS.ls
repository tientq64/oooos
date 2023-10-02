class OS extends Task
   (app, env) ->
      os := @

      @isOS = yes

      @apps = [app]
      @tasks = []

      @taskbarHeight = 39

      @desktopWidth = void
      @desktopHeight = void
      @updateDesktopSize!

      @time = dayjs!

      super app, env

   oncreate: (vnode) !->
      super vnode

      await fs.init do
         bytes: 1024 * 1024 * 512

      for path in Paths\/C/apps/*
         name = @namePath path
         await @installApp \boot path, path, "/C/appData/#name"

      window.addEventListener \resize @onresizeGlobal
      window.addEventListener \message @onmessageGlobal

      m.redraw!

      @runTask \Test

   updateDesktopSize: !->
      @desktopWidth = innerWidth
      @desktopHeight = innerHeight - @taskbarHeight

   onresizeGlobal: (event) !->
      @updateDesktopSize!
      for task in os.tasks
         task.resizeTask!

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

   view: (vnode) ->
      super vnode,
         m \.OS,
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
                     m Button,
                        basic: yes
                        width: 200
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
