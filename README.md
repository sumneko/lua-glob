# lua-glob

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
