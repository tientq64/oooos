{{compsM}}

osTask = void

pack = await m.fetch \package.json \json

app =
   name: pack.displayName
   path: \/
   type: \os
   icon: \fad:egg-fried
   version: pack.version
   author: pack.author
   admin: yes
   focusable: no
   fullscreen: yes
   noHeader: yes
   skipTaskbar: yes
   supportedExts: []
   description: pack.description
   license: pack.license

new OS app

osTask = os

m.mount document.body, os
