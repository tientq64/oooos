await os.import do
   \pdfjs-dist@3.11.174
   \pdfjs-dist@3.11.174/build/pdf.worker.min.js
   \pdfjs-dist@3.11.174/web/pdf_viewer.min.css

App = m.comp do
   oncreate: !->
      os.addListener \ents @onEnts

   lazyLoadPages: !->
      @loading = yes
      start = @numPage
      end = Math.min start + 10, @pdf.numPages + 1
      for numPage from start til end
         page = await @pdf.getPage numPage
         viewport = page.getViewport do
            scale: 1.5
         canvas = document.createElement \canvas
         canvas.width = viewport.width
         canvas.height = viewport.height
         context = canvas.getContext \2d
         renderTask = page.render do
            canvasContext: context
            viewport: viewport
         await renderTask.promise
         @pagesVnode.dom.appendChild canvas
         @numPage++
      @loading = no
      m.redraw!

   onEnts: (ents) !->
      @ent = ents.0
      @pdf = void
      @numPage = 1
      @loading = no
      m.redraw!
      buf = await os.readFile @ent, \arrayBuffer
      loadingTask = pdfjsLib.getDocument do
         data: buf
      @pdf = await loadingTask.promise
      await @lazyLoadPages!
      m.redraw!

   onscrollPages: (event) !->
      event.redraw = no
      unless @loading
         el = event.target
         if el.scrollTop + el.scrollWidth + 1000 >= el.scrollHeight
            @lazyLoadPages!

   view: ->
      m \.column.gap-1.h-100p,
         m \.col-0.px-1,
            m Menubar,
               menus:
                  *  text: "Tệp"
                     subitems:
                        *  text: "Thoát"
                           icon: \xmark
                           color: \red
                           click: !~>
                              os.close!
         @pagesVnode =
            m \.col.text-center.ov-auto,
               onscroll: @onscrollPages
