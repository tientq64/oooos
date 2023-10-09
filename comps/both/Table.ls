Table = m.comp do
   view: ->
      m \.Table,
         class: m.class do
            "Table--fill": @attrs.fill
            "Table--striped": @attrs.striped
            "Table--fixed": @attrs.fixed
            "Table--truncate": @attrs.truncate
            "Table--interactive": @attrs.interactive
            @attrs.class
         style: m.style do
            @attrs.style
         onpointerdown: @attrs.onpointerdown
         onpointermove: @attrs.onpointermove
         onpointerup: @attrs.onpointerup
         onlostpointercapture: @attrs.onlostpointercapture
         onclick: @attrs.onclick
         oncontextmenu: @attrs.oncontextmenu
         m \table.Table-table,
            @children
