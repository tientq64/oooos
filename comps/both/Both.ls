class Both
   ->
      m.bind @

      @incrId = 0

      @dom = void
      @contextMenuList = []
      @contextMenuResolves = []

   oncreate: (vnode) !->
      @dom = vnode.dom

      window.addEventListener \contextmenu @oncontextmenuGlobalBoth

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

   castArr: (arr) ->
      if Array.isArray arr => arr
      else if arr? => [arr]
      else []

   castNewArr: (arr) ->
      if Array.isArray arr => [...arr]
      else if arr? => [arr]
      else []

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

   formatIconName: (name) ->
      if name?
         name = String name
         if /^\d{2,}$/.test name
            name = "flaticon:#name"
         else if !name.includes \:
            name = "fas:#name"
         [kind, ...val] = name.split \:
         val .= join \:
      else
         kind = \blank
      val = switch kind
         | \flaticon => "https://cdn-icons-png.flaticon.com/128/#{val.slice 0 -3 or 0}/#val.png"
         | \https \http => "#kind:#val"
         else val
      [kind, val]

   formatMenuItems: (items, parentId, groups) ->
      parentId ?= ""
      groups ?= Object.create null
      newItems = []
      clicks = {}
      newGroups = {}
      prevItem = void
      openingGroups = new Set
      items = @castArr items
         .map (item) ~>
            item ? divider: yes
         .filter (item) ~>
            (!item.hidden) and (\visible !of item or item.visible)
         .flatMap (item) ~>
            if item.includeGroup
               groups[that] or []
            else item
      for item, i in items
         newItem = void
         id = "#parentId:#i"
         if item.divider
            newItem = item
            if prevItem
               if prevItem.divider or prevItem.isHeader
                  newItems.pop!
         else if item.beginGroup
            openingGroups.add that
         else if item.endGroup
            openingGroups.delete that
         else if \header of item
            newItem =
               header: item.header
               isHeader: yes
            if prevItem
               if prevItem.divider or prevItem.isHeader
                  newItems.pop!
         else if typeof! item == \Object
            newItem =
               text: String that if item.text?
               icon: item.icon
               label: String that if item.label?
               color: item.color
               disabled: item.disabled
               isItem: yes
            if item.subitems
               [subitems, subclicks] = @formatMenuItems item.subitems, id
               if subitems
                  newItem.subitems = subitems
                  clicks <<< subclicks
            else if item.click
               clicks[id] = item.click
         if newItem
            newItem.id = id
            if item.group
               newGroups[][item.group]push newItem
            openingGroups.forEach (groupName) !~>
               newGroups[][groupName]push newItem
            newItems.push newItem
            prevItem = newItem
      firstItem = newItems.0
      if firstItem and firstItem.divider
         newItems.shift!
      lastItem = newItems.at -1
      if (lastItem) and (lastItem.divider or lastItem.isHeader)
         newItems.pop!
      if newItems.length == 0
         newItems = void
      [newItems, clicks, newGroups]

   fixBlurryScroll: (event) !->
      event.redraw = no
      event.target.scrollLeft = Math.round event.target.scrollLeft
      event.target.scrollTop = Math.round event.target.scrollTop

   getRect: (el) ->
      rect = el.getBoundingClientRect!
      rect{x, y, width, height, left, top, right, bottom}

   getRectByXY: (x, y) ->
      x: x
      y: y
      width: 0
      height: 0
      left: x
      top: y
      right: x
      bottom: y

   makeFakePopperTargetEl: (rect) ->
      getBoundingClientRect: ~>
         rect

   makeFakePopperTargetElByXY: (x, y) ->
      rect = @getRectByXY x, y
      @makeFakePopperTargetEl rect

   createPopper: (targetEl, popperEl, opts = {}) ->
      Popper.createPopper targetEl, popperEl,
         placement: opts.placement or \auto
         modifiers:
            *  name: \offset
               options:
                  offset: opts.offset
            *  name: \preventOverflow
               options:
                  padding: opts.padding
                  tether: opts.tether
                  tetherOffset: opts.tetherOffset
            *  name: \flip
               options:
                  fallbackPlacements: opts.flips
                  allowedAutoPlacements: opts.allowedFlips

   addContextMenu: (event, ...items) ->
      if typeof items.0 == \function
         items = items.0
      @contextMenuList.push items
      new Promise (resolve) !~>
         @contextMenuResolves.push resolve

   oncontextmenuGlobalBoth: (event) !->
      if event.isTrusted
         event.preventDefault!
         if @contextMenuList.length
            list = @contextMenuList
            resolves = @contextMenuResolves
            @contextMenuList = []
            @contextMenuResolves = []
            items = void
            clicks = {}
            groups = Object.create null
            for items2, i in list
               if typeof items2 == \function
                  items2 = await items2
               [items3, clicks3, groups3] = @formatMenuItems items2, i, groups
               clicks <<< clicks3
               for k, group of groups3
                  groups[][k]push ...group
            items = items3
            clickedItem = await @showContextMenu event.x, event.y, items, @isFrme
            m.redraw!
