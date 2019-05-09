# lua-glob

[![Build status](https://ci.appveyor.com/api/projects/status/2u02fyusb1aw5rs9?svg=true)](https://ci.appveyor.com/project/sumneko/lua-glob)

Require [LPegLabel](https://github.com/sqmedeiros/lpeglabel)

## glob
```lua
local glob = require 'glob'

local pattern = {
    'src',
    '!*.dll',
}
local options = {
    ignoreCase = true
}
local parser = glob.glob(pattern, options)

parser 'Src/main.lua' --> true
parser 'Src/lpeg.dll' --> false
```
