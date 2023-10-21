{{compsM}}

pack = await m.fetch \package.json \json

app =
   name: pack.displayName
   path: \/
   type: \os
   icon: \fad:kiwi-bird
   version: pack.version
   author: pack.author
   admin: yes
   focusable: no
   fullscreen: yes
   noHeader: yes
   description: pack.description
   license: pack.license

new OS app

m.mount document.body, os
