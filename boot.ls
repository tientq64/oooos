Paths = await m.fetch \paths.json \json

globs = <[
   /comps/both/*
   /comps/main/!(OS.ls)
   /comps/main/OS.ls
   /comps/frme/*
   /code/both.ls
   /code/main.ls
   /code/frme.ls
   /styl/decr.styl
   /styl/both.styl
   /styl/main.styl
   /styl/frme.styl
   /frme.html
]>

data = await Promise.all globs.map (glob) ~>
   glob = Paths[glob] or glob
   if Array.isArray glob
      Promise.all glob.map (path) ~>
         m.fetch path
   else
      m.fetch glob

compsB = data.0.join ""
compsM = data[1 2]flat!join ""
compsF = data.3.join ""

codeB = data.4
codeM = data.5
codeF = data.6

stylD = data.7
stylB = data.8
stylM = data.9
stylF = data.10

htmlF = data.11

function indent text, space
   skipFirstLine = yes
   text.replace /^(?=.)/gm ~>
      if skipFirstLine
         skipFirstLine = no
         ""
      else space

importVarCode = """
   text => text.replace(/(^ +)?\\{\\{([\\w@.]+)}}/gm, (_, space, name) => {
      name = name.replace("@", "this.");
      let val = eval(name);
      if (space) val = indent(val, space);
      return val;
   });
"""
importVar = eval importVarCode

code = importVar codeM
code = importVar codeB
code = livescript.compile code
eval code

styl = stylM
styl = importVar stylB
styl = stylus.render styl, compress: yes
stylEl.textContent = styl
