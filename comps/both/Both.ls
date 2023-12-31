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
      @listeners = {}

   oncreate: (vnode) !->
      @dom = vnode.dom

      window.addEventListener \contextmenu @oncontextmenuGlobalBoth

   castStr: (str) ->
      if str? => String str
      else ""

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

   castNum: (val, defaultVal = 0) ->
      | isNaN val => defaultVal
      | val? => Number val
      else defaultVal

   clamp: (num, min, max) ->
      max = [, 1 min, max][&length]
      min = [, 0 0 min][&length]
      num =
         | num < min => min
         | num > max => max
         else num
      Number num

   random: (min, max) ->
      max = [1 min, max][&length]
      min = [0 0 min][&length]
      min + Math.floor Math.random! * (max - min + 1)

   randomUuid: ->
      crypto.randomUUID!

   getIncrId: ->
      @incrId += 1

   castArr: (arr) ->
      | Array.isArray arr => arr
      | arr? => [arr]
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
      | typeof! obj == \Object => obj
      | obj? and key != void => (key): obj
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

   addListener: (name, callback) !->
      if @isFunc callback
         listener = @listeners[name]
         unless listener
            listener =
               callbacks: []
            @listeners[name] = listener
         listener.callbacks.push callback

   removeListener: (name, callback) !->
      if @isFunc callback
         if listener = @listeners[name]
            @removeArr listener.callbacks, callback

   formatIconName: (name) ->
      if name == no
         kind = \none
      else if name in [void null "" \blank]
         kind = \blank
      else
         [, kind, val, color] = /^(?:(\w+):)?(.+?)(?:!([\da-fA-F]{3,8}))?$/.exec name
         if /^\d{2,}$/.test val
            kind ?= \flaticon
         kind ?= \fas
         val = switch kind
            | \flaticon => "https://cdn-icons-png.flaticon.com/128/#{val.slice 0 -3 or 0}/#val.png"
            | \https \http => "#kind:#val"
            else val
         color = \# + color
      [kind, val, color]

   formatMenuItems: (items, parentId, groups) ->
      parentId ?= ""
      groups ?= Object.create null
      newItems = []
      clicks = {}
      newGroups = {}
      allItems = []
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
                  [subitems, subclicks,, subAllItems] = @formatMenuItems item.subitems, id
                  if subitems
                     newItem.subitems = subitems
                     clicks <<< subclicks
                  allItems.push ...subAllItems
               else if item.click
                  clicks[id] = item.click
         if newItem
            newItem.id = id
            if item.group
               newGroups[][item.group]push newItem
            openingGroups.forEach (groupName) !~>
               newGroups[][groupName]push newItem
            newItems.push newItem
            allItems.push newItem
            prevItem = newItem
      firstItem = newItems.0
      if firstItem and firstItem.divider
         newItems.shift!
      lastItem = newItems.at -1
      if lastItem and (lastItem.divider or lastItem.isHeader)
         newItems.pop!
      if newItems.length == 0
         newItems = void
      [newItems, clicks, newGroups, allItems]

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
            placements = @uniqueNewArr placements.map (or \auto)
            text .= substring 0 index
         else
            placements = [\auto]
      [text, placements]

   createHist: (items, max, duplicate, redraw) ->
      items = @castNewArr items
      hist =
         max: max or 1000
         duplicate: Boolean duplicate
         redraw: Boolean redraw
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
            unless !hist.duplicate and hist.items.length and item == hist.item
               if hist.index < hist.items.length - 1
                  hist.items.splice hist.index + 1
               hist.items.push item
               if hist.items.length > hist.max
                  hist.items.shift!
               hist.index = hist.items.length - 1
               hist.update!
         insert: (item, at = hist.items.length, offsetIndexAfterInsert = 0) !~>
            if at < 0
               at = hist.items.length + at
               at = 0 if at < 0
            else if at > hist.items.length
               at = hist.items.length
            unless !hist.duplicate and hist.items.length and at > 0 and item == hist.item[at - 1]
               hist.items.splice at, 0 item
               if hist.items.length > hist.max
                  hist.items.shift!
                  at--
               hist.index = at
            else
               hist.index = at - 1
            if offsetIndexAfterInsert
               index2 = hist.index + offsetIndexAfterInsert
               if 0 <= index2 < hist.items.length
                  hist.index = index2
            hist.update!

         update: !~>
            hist.item = hist.items[hist.index]
            hist.canGoBack = hist.index > 0
            hist.canGoForward = hist.index < hist.items.length - 1
            m.redraw! if hist.redraw
      hist.update!
      hist

   createRouter: (mountEl, routes) ->
      for pattern, comp of routes
         unless pattern.0 == \/
            throw Error "Đường dẫn phải bắt đầu với /"
         trigger = pattern.replace /\/(?:(?::(\w+))(\.{3})?|(\.{3}))/g (, name, dots, dots2) ~>
            if dots2
               \/.+
            else
               val = dots and \.+ or \\\w+
               val = "(?<#name>#val)" if name
               "/#val"
         trigger = RegExp "^#{trigger}$"
         route =
            pattern: pattern
            comp: comp
            trigger: trigger
         routes[pattern] = route
      router =
         routes: routes
         route: void
         path: void
         hist: @createHist!
         back: !~>
            if item = router.hist.back!
               router.set item.0, item.1, yes
         forward: !~>
            if item = router.hist.forward!
               router.set item.0, item.1, yes
         canGoBack:~->
            router.hist.canGoBack
         canGoForward:~->
            router.hist.canGoForward
         set: (path, attrs, dontPushHist) ~>
            for pattern, route of router.routes
               if result = route.trigger.exec path
                  router.route = route
                  router.path = path
                  attrs = @castNewObj attrs
                  if result.groups
                     attrs <<< that
                  attrs.key = path
                  m.mount mountEl,
                     view: ~>
                        m route.comp, attrs
                  unless dontPushHist
                     router.hist.push [path, attrs]
                  break
      router

   stopPropagation: (event) !->
      event.redraw = no
      event.stopPropagation!

   fixBlurryScroll: (event) !->
      event.redraw = no
      event.target.scrollLeft = Math.round event.target.scrollLeft
      event.target.scrollTop = Math.round event.target.scrollTop

   cssObjectFitToBackgroundSize: (val) ->
      switch val
      | \cover \contain => val
      | \fill => "100% 100%"
      | \none => \auto

   getRect: (el, isReturnArr) ->
      if typeof el == \string
         el = document.querySelector el
      rect = el.getBoundingClientRect!
      if isReturnArr
         [rect.x, rect.y, rect.width, rect.height, rect.right, rect.bottom]
      else
         rect{x, y, width, height, right, bottom, left, top}

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
      await Promise.all libs.map (lib, i) !~>
         result = os.importedLibs[lib]
         if result == void
            result = new Promise (resolve, reject) !~>
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
                     el.onload = !~>
                        resolve!
                     el.onerror = (,,,, err) !~>
                        el.remove!
                        delete os.importedLibs[lib]
                        reject err
                     el.src = url
                     document.body.appendChild el
                  else
                     el = document.createElement \link
                     el.rel = \stylesheet
                     el.onload = !~>
                        resolve!
                     el.onerror = (,,,, err) !~>
                        el.remove!
                        delete os.importedLibs[lib]
                        reject err
                     el.href = url
                     stylLibEl.after el
               | \import
                  try
                     modl = await import url
                     varName = name
                        .replace /^[^a-z\d]+|(?<=.)@[\d.]+$/g ""
                        .replace /[^a-z\d]+([a-z])/g (.at -1 .toUpperCase!)
                     window[varName] = modl
                     resolve!
                  catch
                     delete os.importedLibs[lib]
                     reject e
            os.importedLibs[lib] = result
         await result
         m.redraw!

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
