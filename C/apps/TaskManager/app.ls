App = m.comp do
   oninit: !->
      @task = void
      @lastUpdatedTime = Date.now!

   oncreate: !->
      os.addListener \tasks @onTasks
      os.requestPerm \tasksView

   getMenubarMenus: ->
      *  *  text: "Tệp"
            subitems:
               *  text: "Thoát"
                  icon: \xmark
                  color: \red
                  click: !~>
                     os.close!
         *  text: "Chọn"
            subitems:
               *  text: "Tập trung vào tác vụ đã chọn"
                  icon: \bullseye-pointer
                  enabled: @task
                  click: !~>
                     os.focusTask @task.pid
               ,,
               *  text: "Đóng tác vụ đã chọn"
                  icon: \xmark
                  color: \red
                  enabled: @task and @task.type != \os
                  click: !~>
                     os.closeTask @task.pid

   onTasks: !->
      @task and= os.tasks.find (.pid == @task.pid)
      @lastUpdatedTime = Date.now!

   onmousedownTasks: (event) !->
      if event.target == event.currentTarget
         @task = void

   onmousedownTask: (task, event) !->
      @task = task

   oncontextmenuTask: (task, event) !->
      await os.addContextMenu event,
         *  text: "Tập trung vào tác vụ"
            icon: \bullseye-pointer
            click: !~>
               os.focusTask task.pid
         ,,
         *  text: "Đóng tác vụ"
            icon: \xmark
            color: \red
            enabled: task.type != \os
            click: !~>
               os.closeTask task.pid

   view: ->
      m \.column.gap-1.h-100p.p-3.pt-0,
         m \.col-0,
            m Menubar,
               menus: @getMenubarMenus!
         m \.col,
            onmousedown: @onmousedownTasks
            m Table,
               class: "max-h-100p"
               striped: yes
               fixed: yes
               truncate: yes
               interactive: yes
               m \thead,
                  m \tr,
                     m \th.col-3,
                        "Tên"
                     m \th.col-1,
                        "Pid"
                     m \th.col-1,
                        "Loại"
                     m \th.col-4,
                        "Đường dẫn"
                     m \th.col-1,
                        "Admin"
                     m \th.col-1,
                        "Ẩn"
                     m \th.col-1,
                        "Z"
               m \tbody,
                  os.tasks?map (task) ~>
                     m \tr,
                        key: task.pid
                        class: m.class do
                           "bg-blue3": task.pid == @task?pid
                        onmousedown: @onmousedownTask.bind void task
                        oncontextmenu: @oncontextmenuTask.bind void task
                        m \td.row.middle.gap-2,
                           m Icon,
                              name: task.icon
                           task.name
                        m \td,
                           task.pid
                        m \td,
                           task.type
                        m \td,
                           task.path
                        m \td,
                           String task.admin
                        m \td,
                           String task.hidden
                        m \td,
                           task.z
         m \.col-0.row,
            m \.col-0,
               "Thời gian cập nhật lần cuối: #{dayjs @lastUpdatedTime .format "HH:mm:ss.SSS"}"
