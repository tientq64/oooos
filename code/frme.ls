[[compsF]]

os = new Frme
os.tid = "[[@tid]]"

m.mount document.body, os

data = await os.initTaskFrme!
os.tid = data.tid

await (!->
   [[code]]

   m.mount os.bodyEl, App
)!
