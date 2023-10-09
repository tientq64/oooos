{{compsF}}

os = new Frme
os.tid = "{{@tid}}"

m.mount document.body, os

$ = await os.initTaskFrme!
os.tid = $.tid
os.args = $.args

await (!->
   $ = void

   {{code}}

   m.mount os.bodyEl, App
)!

if $.autoListen
   os.startListen!
