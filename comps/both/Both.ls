class Both
   ->
      m.bind @

      @incrId = 0

      @dom = void

      @contextMenuList = []
      @contextMenuResolves = []

      @importedLibs = Object.create null

      @resolvers = {}

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

   safeApply: (fn, args) ->
      try
         result = fn? ...args
         isErr = no
      catch e
         result = e
         isErr = yes
         console.error e
      [result, isErr]

   safeCall: (fn, ...args) ->
      @safeApply fn, args

   safeCastVal: (fn, ...args) ->
      if typeof fn == \function
         @safeApply fn, args
      else
         [fn, no]

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

   joinPath: (...paths) ->
      index = paths.findLastIndex (.0 == \/)
      if index > 0
         paths .= slice index
      path = paths.join \/
      @normPath path

   absPath: (path) ->
      [nodes] = @splitPath path
      \/ + nodes.join \/

   relPath: (path) ->
      [nodes] = @splitPath path
      nodes.join \/

   dirPath: (path) ->
      [nodes, root] = @splitPath path
      root + nodes.slice 0 -1 .join \/

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
         [, kind, val, color] = /^(?:(\w+):)?(.+?)(?:!([\da-fA-F]{3,8}))?$/.exec name
         if /^\d{2,}$/.test val
            kind ?= \flaticon
         kind ?= \fas
         val = switch kind
            | \flaticon => "https://cdn-icons-png.flaticon.com/128/#{val.slice 0 -3 or 0}/#val.png"
            | \https \http => "#kind:#val"
            else val
         color = \# + color
      else
         kind = \blank
      [kind, val, color]

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
         id = item.id ? "#parentId:#i"
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

   createHist: (items, max) ->
      items = @castNewArr items
      hist =
         max: max or 1000
         items: items
         index: items.length - 1
         goto: (index) ~>
            if 0 <= index < hist.items.length
               hist.index = index
               hist.update!
               hist.item
         back: ~>
            hist.goto hist.index - 1
         forward: ~>
            hist.goto hist.index + 1
         push: (item) !~>
            if hist.index < hist.items.length - 1
               hist.items.splice hist.index + 1
            hist.items.push item
            if hist.items.length > hist.max
               hist.items.shift!
            hist.index = hist.items.length - 1
            hist.update!
         insert: (item, at = -2) !~>
            hist.items.splice at, 0 item
            if hist.items.length > hist.max
               hist.items.shift!
            hist.index = hist.items.length - 1
         update: !~>
            hist.item = hist.items[hist.index]
            hist.canGoBack = hist.index > 0
            hist.canGoForward = hist.index < hist.items.length - 1
      hist.update!
      hist

   stopPropagation: (event) !->
      event.redraw = no
      event.stopPropagation!

   fixBlurryScroll: (event) !->
      event.redraw = no
      event.target.scrollLeft = Math.round event.target.scrollLeft
      event.target.scrollTop = Math.round event.target.scrollTop

   getRect: (el) ->
      rect = el.getBoundingClientRect!
      rect{x, y, width, height, left, top, right, bottom}

   makeRectFromXY: (x, y) ->
      x: x
      y: y
      width: 0
      height: 0
      left: x
      top: y
      right: x
      bottom: y

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

   import: (...libs) !->
      listJs = []
      listCss = []
      await Promise.all libs.map (lib, i) ~>
         promise = os.importedLibs[lib]
         unless promise
            promise = new Promise (resolve) !~>
               [, kind, name, ext] = lib.match /^(?:(npm|git|sky):)?(.+?)(?:!(js|css))?$/
               kind or= \npm
               ext or= name.endsWith \.css and \css or \js
               loadType = \fetch
               switch kind
               | \npm
                  url = "https://cdn.jsdelivr.net/npm/#name"
               | \git
                  url = "https://cdn.jsdelivr.net/gh/#name"
               | \sky
                  url = "https://cdn.skypack.dev/#name?min"
                  loadType = \import
               switch loadType
               | \fetch
                  text = await m.fetch url
               | \import
                  modl = await import url
               if text
                  if ext == \css
                     listCss[i] = text
                  else
                     listJs[i] = text
               else if modl
                  varName = name
                     .replace /^[^a-z\d]+|(?<=.)@[\d.]+$/g ""
                     .replace /[^a-z\d]+([a-z])/g (.at -1 .toUpperCase!)
                  listJs[i] = [varName, modl]
               resolve!
         promise
      if listJs.length
         for js in listJs
            if Array.isArray js
               window[js.0] = js.1
            else
               window.eval js
      if listCss.length
         css = listCss.join \\n .concat \\n
         stylLibsEl.textContent += css

   addResolver: ->
      mid = @randomUuid!
      promise = new Promise (resolve, reject) !~>
         resolver =
            resolve: resolve
            reject: reject
         @resolvers[mid] = resolver
      [mid, promise]

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
            if clickedItem
               clicks[clickedItem.id]? clickedItem
            for resolve in resolves
               resolve clickedItem
            m.redraw!
