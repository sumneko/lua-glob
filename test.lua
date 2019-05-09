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
    : no 'examplea'

test('example', { ignoreCase = true })
    : ok 'example'
    : ok 'Example'
    : no 'aexample'

test '/example'
    : ok 'example'
    : ok 'example/xx'
    : no 'xx/example'

test '/a/b'
    : ok 'a/b'
    : ok 'a/b/c'
    : no 'b/a/b'

test './a'
    : ok 'a'
    : ok 'a/b'
    : no 'b/a'

test [[
a
b
]]
    : ok 'a'
    : ok 'b'
    : ok 'ccc/a'
    : ok 'ccc/b'
    : no 'c'

test [[
a
!b
]]
    : ok 'a'
    : no 'b'
    : no 'b/a'
    : no 'a/b'
    : no 'c/b'
    : ok 'c/a'

test [[
a
!/a
]]
    : no 'a'
    : ok 'b/a'

test '**/a'
    : ok 'a'
    : ok 'b/a'
    : ok 'c/b/a'
    : ok 'a/b'
    : ok 'c/a/b'
    : no 'b'

test '**a'
    : ok 'a'
    : ok 'b/a'
    : ok 'c/b/a'
    : ok 'a/b'
    : ok 'c/a/b'
    : no 'b'

test 'a/**/b'
    : ok 'a/b'
    : ok 'a/c/b'
    : ok 'd/a/c/d/e/b'
    : no 'a'
    : no 'b'

test 'a**b'
    : ok 'a/b'
    : ok 'a/c/b'
    : ok 'd/a/c/d/e/b'
    : no 'a'
    : no 'b'

test 'a/**b'
    : ok 'a/b'
    : ok 'a/c/b'
    : ok 'd/a/c/d/e/b'
    : no 'a'
    : no 'b'

test 'a**/b'
    : ok 'a/b'
    : ok 'a/c/b'
    : ok 'd/a/c/d/e/b'
    : no 'a'
    : no 'b'

test '{a, b}'
    : ok 'a'
    : ok 'b'
    : ok 'c/a'
    : ok 'c/b'
    : no 'c'

test 'a*'
    : ok 'a'
    : ok 'ab'
    : ok 'ab/c'
    : ok 'c/a'
    : ok 'c/ab'
    : no 'ba'
    : no 'bac'

test 'a*b'
    : ok 'ab'
    : ok 'acb'
    : ok 'a/ab'
    : ok 'aaaabbb'
    : no 'abc'
    : no 'a/b'

test '{**/*.html, **/*.txt}'
    : ok '1.html'
    : ok '1.txt'
    : ok 'a/b.html'
    : ok 'a/b.txt'
    : no '1.lua'

print('Test done.')
