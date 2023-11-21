Icon = m.comp do
   onbeforeupdate: !->
      [@kind, @val, @color] = os.formatIconName @attrs.name
      @size = @attrs.size or 16

   view: ->
      switch @kind
      | \flaticon \https \http
         m \img.Icon.Icon--img,
            class: m.class do
               @attrs.class
            style: m.style do
               width: @size
               height: @size
               @attrs.style
            src: @val
      | \blank
         m \.Icon.Icon--blank,
            class: m.class do
               @attrs.class
            style: m.style do
               width: @size
               height: @size
               @attrs.style
      | \none
         void
      else
         m \.Icon.Icon--font,
            class: m.class do
               "Icon--compact": @attrs.compact
               "#@kind fa-#@val"
               @attrs.class
            style: m.style do
               width: @size
               height: @size
               fontSize: @size
               color: @color
               @attrs.style
