local glob = require 'glob'

local mt = {}
mt.__index = mt

function mt:ok(path)
    assert(self.matcher(path) == true)
    return self
end

function mt:no(path)
    assert(self.matcher(path) ~= true)
    return self
end

function mt:op(key)
    self.matcher:setOption(key)
    return self
end

local function test(pattern, options)
    local matcher = glob.gitignore(pattern, options)
    return setmetatable({
        matcher = matcher
    }, mt)
end

print 'Test gitignore ...'
test {'src', '!*.dll'}
    : op 'ignoreCase'
    : ok 'Src/main.lua'
    : no 'Src/lpeg.dll'
