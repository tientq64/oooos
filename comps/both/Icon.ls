Icon = m.comp do
   onbeforeupdate: !->
      {name} = @attrs
      if /^\d+$/.test name
         name = "flaticon:#name"
      else if !name.includes \:
         name = "fas:#name"
      [kind, val] = name.split \:
      @kind = kind
      @val = switch kind
         | \fa \fas \far \fad \fab => val
         | \flaticon => "https://cdn-icons-png.flaticon.com/128/#{val.slice 0 -3}/#val.png"
         else "#kind:#val"

   view: ->
      switch @kind
      | \fa \fas \far \fad \fab
         m \.Icon.Icon--font,
            class: m.class do
               "#@kind fa-#@val"
               @attrs.class
      else
         m \img.Icon.Icon--img,
            class: m.class do
               @attrs.class
            src: @val
