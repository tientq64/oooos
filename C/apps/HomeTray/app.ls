os.import do
   \rss-parser@3.13.0/dist/rss-parser.min.js

App = m.comp do
   oninit: !->
      @rssParser = void

   onbeforeupdate: !->
      if window.RSSParser and @rssParser == void
         @rssParser = new RSSParser
         @feed = await @rssParser.parseURL \https://nocors.vercel.app/api/get?type=text&url=https://vnexpress.net/rss/tin-moi-nhat.rss
         for item in @feed.items
            item.image = item.content.match /<img src="(.+?)" >/ ?.1

   view: ->
      m \.column.gap-3.h-100p.p-3.pt-2,
         m \.row.between.middle,
            m \h2,
               os.osName
            m \.text-gray2,
               "Phiên bản #{os.osVersion}"
         m \.col.column.gap-6.mx-n3.px-3.ov-auto,
            if @feed
               @feed.items.map (item) ~>
                  m \.column.gap-1,
                     m \div,
                        item.title
                     m \div,
                        m \img.w-32.mr-4.rounded.float-left,
                           src: item.image
                        m \.text-6.text-gray2,
                           item.contentSnippet
         m \.border-t.border-gray3
         m \.row.end.middle.gap-1,
            m Button,
               fill: yes
               basic: yes
               icon: \lock-keyhole
               "Khóa m.hình"
            m Button,
               fill: yes
               basic: yes
               color: \red
               icon: \power-off
               "Tắt nguồn"
