App = m.comp do
   oninit: !->
      @task = void

   oncreate: !->
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
               *  text: "Đóng tác vụ đã chọn"
                  icon: \xmark
                  color: \red
                  enabled: @task and @task.type != \os
                  click: !~>
                     os.closeTask @task.pid

   onclickTasks: (event) !->
      if event.target == event.currentTarget
         @task = void

   onmousedownTask: (task, event) !->
      @task = task

   oncontextmenuTask: (task, event) !->
      await os.addContextMenu event,
         *  text: "Đóng tác vụ"
            icon: \xmark
            color: \red
            enabled: task.type != \os
            click: !~>
               os.closeTask task.pid

   view: ->
      m \.column.gap-1.h-100.p-3.pt-0,
         m \.col-0,
            m Menubar,
               menus: @getMenubarMenus!
         m \.col,
            onclick: @onclickTasks
            m Table,
               class: "max-h-100"
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
                     m \th.col-2,
                        "Loại"
                     m \th.col-1,
                        "Admin"
                     m \th.col-5,
                        "Đường dẫn"
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
                           String task.admin
                        m \td,
                           task.path
