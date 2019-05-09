require 'utility'
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

local function test(patternStr, options)
    local pattern = {}
    for l in patternStr:gmatch '[^\r\n]+' do
        pattern[#pattern+1] = l
    end
    local matcher = glob.glob(pattern, options)
    return setmetatable({
        matcher = matcher
    }, mt)
end

print('Test start.')

test 'example'
    : ok 'example'
    : ok 'abc/example'
    : ok 'abc/bcd/example'
    : ok 'example/ddd'
    : ok 'abc/example/ddd'
    : ok 'abc/bcd/example/ddd'
    : ok 'abc/bcd\\example/ddd'
    : ok 'example/'
    : no 'Example'
    : no 'aexample'

test('example', { ignoreCase = true })
    : ok 'example'
    : ok 'Example'

print('Test done.')
