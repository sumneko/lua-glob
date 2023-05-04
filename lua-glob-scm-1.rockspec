rockspec_format = "3.0"
package = "lua-glob"
version = "scm-1"
source = {
   url = "git+https://github.com/sumneko/lua-glob",
   branch = "master",
}
description = {
   summary = "glob and gitignore pattern matchers for lua",
   homepage = "https://github.com/sumneko/lua-glob",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
   "lpeglabel ~> 1",
}
build = {
   type = "builtin",
   modules = {
      ["glob"] = "glob/init.lua",
      ["glob.glob"] = "glob/glob.lua",
      ["glob.gitignore"] = "glob/gitignore.lua",
      ["glob.matcher"] = "glob/matcher.lua",
   },
}
test = {
   type = "command",
   script = "test/init.lua",
}
