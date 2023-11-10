App = m.comp do
   oninit: !->
      @atoms = []
      @groups = []
      @radius = 3
      @gMaps = []

   oncreate: !->
      @updateSize!
      @addGroup 200 \#e11d48
      @addGroup 200 \#d97706
      @addGroup 200 \#16a34a
      @addGroup 200 \#2563eb
      @addGroup 200 \#475569
      @addGroup 200 \#7c3aed
      @addGroup 200 \#0891b2
      @addGroup 200 \#c026d3
      @addGroup 200 \#fff
      @render!
      window.addEventListener \resize @updateSize
      m.redraw!

   render: !->
      for group in @groups
         for group2 in @groups
            @rule group.atoms, group2.atoms, @gMaps[group.color][group2.color]
      @g.clearRect 0 0 @width, @height
      @g.fillStyle = \black
      @g.fillRect 0 0 @width, @height
      for atom in @atoms
         x = atom.x - @radius
         y = atom.y - @radius
         diameter = @radius * 2
         @g.fillStyle = atom.color
         @g.fillRect x, y, diameter, diameter
      requestAnimationFrame @render

   updateSize: !->
      @width = @viewerVnode.dom.offsetWidth
      @height = @viewerVnode.dom.offsetHeight
      @canvasVnode.dom.width = @width
      @canvasVnode.dom.height = @height
      @g = @canvasVnode.dom.getContext \2d

   addGroup: (num, color) !->
      group =
         color: color
         atoms: []
      for i til num
         atom =
            x: os.random @width * 0.25, @width * 0.75
            y: os.random @height * 0.25, @height * 0.75
            vx: 0
            vy: 0
            color: color
         group.atoms.push atom
         @atoms.push atom
      @groups.push group
      for group in @groups
         for group2 in @groups
            @gMaps{}[group.color][group2.color] ?= 0
      m.redraw!

   rule: (atoms, atoms2, g) !->
      for atom in atoms
         fx = 0
         fy = 0
         for atom2 in atoms2
            continue if atom == atom2
            dx = atom.x - atom2.x
            dy = atom.y - atom2.y
            d = Math.sqrt dx * dx + dy * dy
            if d > 0 and d < 160
               f = g * 1 / d
               fx += f * dx
               fy += f * dy
         atom.vx = (atom.vx + fx) * 0.5
         atom.vy = (atom.vy + fy) * 0.5
         atom.x += atom.vx
         atom.y += atom.vy
         if atom.x < @radius or atom.x >= @width - @radius
            # atom.vx *= -1
            atom.x = @width / 2
         if atom.y < @radius or atom.y >= @height - @radius
            # atom.vy *= -1
            atom.y = @height / 2

   getBgColorByG: (g) ->
      if g > 0
         "rgba(0, 128, 0, #g)"
      else if g < 0
         "rgba(255, 0, 0, #{-g})"
      else
         \#0000

   onclickG: (g, groupA, groupB, event) !->
      @gMaps[groupA.color][groupB.color] = Number (g + 0.1)toFixed 2

   onauxclickG: (g, groupA, groupB, event) !->
      if event.button = 1
         @gMaps[groupA.color][groupB.color] = 0

   oncontextmenuG: (g, groupA, groupB, event) !->
      @gMaps[groupA.color][groupB.color] = Number (g - 0.1)toFixed 2

   onclickRandomG: (event) !->
      for k, val of @gMaps
         for k2, g of val
            val[k2] = Number ((os.random -10 10) / 10)toFixed 2

   view: ->
      m \.column.h-100,
         m \.col-0,
            m Menubar,
               menus:
                  *  text: "Tệp"
                     subitems:
                        *  text: "Thoát"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
         m \.col.row,
            m \.col-0.p-3,
               style: m.style do
                  width: 280
               m \div,
                  "Lực tương tác:"
               m \.grid,
                  style: m.style do
                     gridTemplateColumns: "repeat(#{@groups.length + 1}, 1fr)"
                     gridAutoRows: 32
                     gap: 2
                  m \.div,
                     "\xa0"
                  @groups.map (group) ~>
                     m \.div,
                        style:
                           background: group.color
                  @groups.map (groupA) ~>
                     m.fragment do
                        m \.div,
                           style:
                              background: groupA.color
                        @groups.map (groupB) ~>
                           g = @gMaps[groupA.color][groupB.color]
                           m \.flex.center.middle,
                              style:
                                 background: @getBgColorByG g
                              onclick: @onclickG.bind void g, groupA, groupB
                              onauxclick: @onauxclickG.bind void 0 groupA, groupB
                              oncontextmenu: @oncontextmenuG.bind void g, groupA, groupB
                              g > 0 and \+
                              (g * 10)toFixed 0
               m \div,
                  m Button,
                     onclick: @onclickRandomG
                     "Ngẫu nhiên"
            @viewerVnode =
               m \.col,
                  @canvasVnode =
                     m \canvas
