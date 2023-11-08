{{compsF}}

os = new Frme
os.tid = "{{@tid}}"

m.mount document.body, os

$ = await os.initTaskFrme!
os <<< $
m.redraw!

await (!->
   $ = void

   {{code}}

   m.mount os.bodyEl, App
)!

if $.autoListen
   os.startListen!
os.loadedFrme!
