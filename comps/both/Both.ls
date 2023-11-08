class Both
   ->
      m.bind @

      @incrId = 0
      @noopFunc = !~>
      @easeIn = "cubic-bezier(.64, 0, .78, 0)"
      @easeOut = "cubic-bezier(.22, 1, .36, 1)"
      @easeInOut = "cubic-bezier(.83, 0, .17, 1)"

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

   indent: (text, amount, skipFirstLine) ->
      space = "   "repeat amount
      text.replace /^(?=.)/gm ~>
         if skipFirstLine
            skipFirstLine := no
            ""
         else space

   escapeHtml: (html) ->
      html.replace /[&<>"']/g (chr) ~>
         "&##{chr.charCodeAt 0};"

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
      arr = @castArr arr
      Array.from arr

   removeArr: (arr, val) ->
      index = arr.indexOf val
      arr.splice index, 1
      arr

   uniqueArr: (arr) ->
      set = new Set arr
      arr.splice 0 Infinity, ...set
      arr

   uniqueNewArr: (arr) ->
      Array.from new Set arr

   castObj: (obj, key) ->
      if typeof! obj == \Object => obj
      else if obj? and key != void => (key): obj
      else {}

   castNewObj: (obj, key) ->
      obj = @castObj obj, key
      {...obj}

   isFunc: (func) ->
      typeof func == \function

   safeSyncApply: (fn, args) ->
      try
         result = fn? ...args
         isErr = no
      catch e
         result = e
         isErr = yes
         console.error e
      [result, isErr]

   safeSyncCall: (fn, ...args) ->
      @safeSyncApply fn, args

   safeSyncCastVal: (fn, ...args) ->
      if typeof fn == \function
         @safeSyncApply fn, args
      else
         [fn, no]

   safeAsyncApply: (fn, args) ->
      try
         result = await fn? ...args
         isErr = no
      catch e
         result = e
         isErr = yes
         console.error e
      [result, isErr]

   safeAsyncCall: (fn, ...args) ->
      @safeAsyncApply fn, args

   safeAsyncCastVal: (fn, ...args) ->
      if typeof fn == \function
         @safeAsyncApply fn, args
      else
         [fn, no]

   promiseAll: (...promises) ->
      Promise.all promises

   promiseAllSettled: (...promises) ->
      Promise.allSettled promises

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
      name.split \. .slice 1 .at -1 or ""

   castPath: (ent) ->
      ent.path or ent

   formatIconName: (name) ->
      if name? and name != ""
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
         if typeof! item == \Object
            id = item.id ? "#parentId:#i"
            if item.divider
               if prevItem and !prevItem.isHeader
                  newItem = item
                  if prevItem.divider
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
            else
               newItem =
                  text: String that if item.text?
                  icon: item.icon
                  label: String that if item.label?
                  color: item.color
                  disabled: Boolean item.disabled
                  active: Boolean item.active
                  value: item.value
                  isItem: yes
               if \enabled of item and !newItem.disabled
                  newItem.disabled = !item.enabled
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
      if lastItem and (lastItem.divider or lastItem.isHeader)
         newItems.pop!
      if newItems.length == 0
         newItems = void
      [newItems, clicks, newGroups]

   formatMenus: (menus) ->
      newMenus = []
      menus = @castArr menus
      for menu, i in menus
         newMenu =
            id: "menus:#i"
            text: menu.text
            icon: menu.icon
            subitems: menu.subitems
         newMenus.push newMenu
      newMenus

   formatTooltip: (text) ->
      text = String text ? ""
      index = text.lastIndexOf \|
      if index == -1
         placements = [\auto]
      else
         placements = text.substring index + 1 .split \,
         if placements.length and
            placements.every (in ["" \left \top \right \bottom \auto]) and
            placements.length == @uniqueNewArr placements .length
         then
            placements .= map (or \auto)
            unless placements.includes \auto
               placements.push \auto
            text .= substring 0 index
         else
            placements = [\auto]
      [text, placements]

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

   checkElIsDark: (el) ->
      Boolean el.closest \.dark

   createPopper: (targetEl, popperEl, opts = {}) ->
      Popper.createPopper targetEl, popperEl,
         placement: opts.placement or \auto
         strategy: \fixed
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
      await Promise.all libs.map (lib, i) ~>
         promise = os.importedLibs[lib]
         unless promise
            promise = new Promise (resolve) !~>
               [, kind, name, ext] = lib.match /^(?:(npm|git|sky):)?(.+?)(?:!(js|css))?$/
               kind or= \npm
               ext or= name.endsWith \.css and \css or \js
               loadType = \tag
               switch kind
               | \npm
                  url = "https://cdn.jsdelivr.net/npm/#name"
               | \git
                  url = "https://cdn.jsdelivr.net/gh/#name"
               | \sky
                  url = "https://cdn.skypack.dev/#name?min"
                  loadType = \import
               switch loadType
               | \tag
                  if ext == \js
                     el = document.createElement \script
                     el.onload = resolve
                     el.src = url
                     document.body.appendChild el
                  else
                     el = document.createElement \link
                     el.rel = \stylesheet
                     el.onload = resolve
                     el.href = url
                     stylLibEl.after el
               | \import
                  modl = await import url
                  varName = name
                     .replace /^[^a-z\d]+|(?<=.)@[\d.]+$/g ""
                     .replace /[^a-z\d]+([a-z])/g (.at -1 .toUpperCase!)
                  window[varName] = modl
                  resolve!
         promise

   wait: (ms) ->
      new Promise (resolve) !~>
         setTimeout resolve, ms

   waitVar: (varName) ->
      new Promise (resolve) !~>
         check = (count) !~>
            if count
               if window[varName]?
                  resolve yes
               else
                  setTimeout !~>
                     check count - 1
                  , 100
            else
               resolve no
         check 100

   addResolver: ->
      mid = @randomUuid!
      promise = new Promise (resolve, reject) !~>
         resolver =
            resolve: resolve
            reject: reject
         @resolvers[mid] = resolver
      [mid, promise]

   resolveResolver: (mid, result, isErr) !->
      if resolver = @resolvers[mid]
         delete @resolvers[mid]
         methodName = isErr and \reject or \resolve
         resolver[methodName] result

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
               [items3, clicks3, groups3] = @formatMenuItems items2, "contextMenu:#i", groups
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
