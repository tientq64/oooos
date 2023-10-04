Icon = m.comp do
   onbeforeupdate: !->
      [@kind, @val] = os.formatIconName @attrs.name

   view: ->
      switch @kind
      | \flaticon \https \http
         m \img.Icon.Icon--img,
            class: m.class do
               @attrs.class
            src: @val
      | \blank
         m \.Icon.Icon--blank,
            class: m.class do
               @attrs.class
      else
         m \.Icon.Icon--font,
            class: m.class do
               "Icon--compact": @attrs.compact
               "#@kind fa-#@val"
               @attrs.class
