Slider = m.comp do
   oninit: !->
      @controlled = \value of @attrs
      @range = void
      @points = []
      @labels = []
      @frac = void
      @value = void
      @dragging = no
      @isOnchange = no
      @tooltipTimeoutId = void

   onbeforeupdate: (old) !->
      @min = os.castNum @attrs.min
      @max = os.castNum @attrs.max, 10
      @step = @attrs.step or 1
      @labelNumber = @attrs.labelNumber ? 6
      @generatePoints!
      if @controlled
         unless @isOnchange
            frac = (@attrs.value - @min) / @range
            if isNaN frac
               @value = void
            else
               @frac = os.clamp frac
               @value = Number @attrs.value
      else if !old
         @frac = 0
         @value = @min
      @isOnchange = no

   onupdate: !->
      if @dragging
         @tooltipTimeoutId = setTimeout !~>
            if @value?
               rect = @thumb.dom.getBoundingClientRect!
               text = "#@value|top,bottom"
               os.showTooltip rect, text, os.darkMode, os.isFrme, 0
         , 100

   generatePoints: !->
      el = document.createElement \input
      el.type = \range
      el.min = @min
      el.max = @max
      el.step = @step
      el.value = @min
      @range = os.clamp @max - @min, 0 @max
      @points = []
      if @range > 0
         do
            val = el.valueAsNumber
            point =
               frac: (val - @min) / @range
               value: val
            @points.push point
            el.stepUp!
            if @min >= @max
               console.log val, @min, @range
         until val == el.valueAsNumber
         @halfPointStep = (@points.1.frac - @points.0.frac) / 2
         if @labelNumber > @points.length
            @labels = @points
         else
            labelStep = (@points.length - 1) / (@labelNumber - 1)
            @labels = Array.from do
               Array @labelNumber .keys!
               (i) ~>
                  index = Math.round i * labelStep
                  @points[index]
      else
         @labels =
            *  frac: 0
               value: @min
            *  frac: 1
               value: @max

   updateByFrac: (frac) ->
      frac -= @halfPointStep
      for point in @points
         if frac <= point.frac
            break
      unless point.frac == @frac and point.value == @value
         @frac = point.frac
         @value = point.value
         yes

   onpointerdown: (event) !->
      event.currentTarget.setPointerCapture event.pointerId
      @dragging = yes
      @onpointermove event
      m.redraw!

   onpointermove: (event) !->
      event.redraw = no
      if @dragging and @range > 0
         rect = event.currentTarget.getBoundingClientRect!
         x = event.x - rect.x - 9
         width = rect.width - 20
         frac = x / width
         if @updateByFrac frac
            @isOnchange = yes
            event.redraw = yes
            os.safeSyncCall @attrs.onValueChange, @value

   onlostpointercapture: (event) !->
      @dragging = no

   onremove: !->
      clearTimeout @tooltipTimeoutId

   view: ->
      m \.Slider,
         onpointerdown: @onpointerdown
         onpointermove: @onpointermove
         onlostpointercapture: @onlostpointercapture
         m \.Slider-track,
            @thumb =
               m \.Slider-thumb,
                  style:
                     left: "#{@frac * 100}%"
                  tooltip: if @value? => "#@value|top,bottom" else ""
         m \.Slider-labels,
            @labels.map (point) ~>
               m \.Slider-label,
                  style:
                     left: "#{point.frac * 100}%"
                  point.value
         @input =
            m \input.Slider-input,
               type: \range
               min: @attrs.min
               max: @attrs.max
               step: @attrs.step
               value: @attrs.value
