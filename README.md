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

## gitignore

### match
```lua
local glob = require 'glob'

local pattern = {
    'src/*',
    '!*.dll',
}
local options = {
    ignoreCase = true
}
local parser = glob.gitignore(pattern, options)

parser 'Src/main.lua' --> true
parser 'Src/lpeg.dll' --> false
```

### scan
Work space
```
main.lua
utility.lua
src
|---test.lua
|---bee.dll
|---lua.dll
```

```lua
local glob = require 'glob'
local fs = require 'bee.filesystem' -- just another filesystem


local pattern = {
    'src/*',
    '!*.dll',
}
local options = {
    ignoreCase = true
}
local interface = {
    type = function (path)
        if not fs.exists(fs.path(path)) then
            return nil
        end
        if fs.is_directory(fs.path(path)) then
            return 'directory'
        else
            return 'file'
        end
    end,
    list = function (path)
        if not fs.exists(fs.path(path)) then
            return nil
        end
        if not fs.is_directory(fs.path(path)) then
            return nil
        end
        local childs = {}
        for child in fs.path(path):list_directory() do
            childs[#childs+1] = child
        end
        return childs
    end,
}

local parser = glob.gitignore(pattern, options, interface)
local files = parser:scan()
print(files[1]) --> main.lua
print(files[2]) --> utility.lua
print(files[3]) --> src\bee.dll
print(files[4]) --> src\lua.dll
print(files[5]) --> nil
```
