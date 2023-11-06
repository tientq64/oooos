require! {
   fs
   "glob-concat"
}

Paths = {}

globs =
   "comps/both/*"
   "comps/main/!(OS.ls)"
   "comps/frme/*"
   "C/apps/*"
   "C/{*,!(apps)/**}"

for glob in globs
   paths = globConcat.sync glob .map (\/ +)
   Paths"/#glob" = paths

json = JSON.stringify Paths,, "   "
fs.writeFileSync \paths.json json
