class Both
   ->
      m.bind @

      @incrId = 0

   upperFirst: (val) ->
      val = String val
      val.charAt 0 .toUpperCase! + val.substring 1

   clamp: (num, min, max) ->
      if &length == 2
         [max, min] = [min 0]
      num =
         if num < min => min
         else if num > max => max
         else num
      Number num

   random: (min, max) ->
      max = [1 min, max][&length]
      min = [0 0 min][&length]
      min + Math.random! * (max - min + 1)

   randomUuid: ->
      crypto.randomUUID!

   getIncrId: ->
      @incrId += 1

   splitPath: (path) ->
      root = ""
      if path.0 == \/
         root = \/
         path .= substring 1
      nodes = []
      vals = path.split \/
      for val in vals
         switch val
         | \. "" =>
         | \.. => nodes.pop!
         else nodes.push val
      [nodes, root]

   normPath: (path) ->
      [nodes, root] = @splitPath path
      root + nodes.join \/

   resolPath: (...paths) ->
      index = paths.findLastIndex (.0 == \/)
      if index >= 0
         paths .= slice index
      newPath = paths
         .map (@normPath <|)
         .join \/
      @normPath newPath

   dirPath: (path) ->
      [nodes, root] = @splitPath path
      root + nodes.slice nodes.length - 1

   namePath: (path) ->
      [nodes] = @splitPath path
      nodes.at -1

   basePath: (path) ->
      name = @namePath path
      base = name.split \.
      base.pop! if base.length > 1
      base.join \.

   extPath: (path) ->
      name = @namePath path
      name.split \. .slice 1 .at 0

   castPath: (ent) ->
      ent.path or ent

   formatMenuItems: (items) ->
      newItems = []
      prevIsDivider = no
      for item in items
         if item == yes
            unless prevIsDivider
               newItem =
                  type: \divider
               prevIsDivider = yes
         else if typeof item == \Object
            0
