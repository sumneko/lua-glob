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
    local matcher = glob.glob(pattern, options)
    return setmetatable({
        matcher = matcher
    }, mt)
end

print 'Test glob ...'
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

test 'example'
    : op 'ignoreCase'
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

test {'a', 'b'}
    : ok 'a'
    : ok 'b'
    : ok 'ccc/a'
    : ok 'ccc/b'
    : no 'c'

test {'a','!b'}
    : ok 'a'
    : no 'b'
    : no 'b/a'
    : no 'a/b'
    : no 'c/b'
    : ok 'c/a'

test {'a','!/a'}
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

test '{a,b}'
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

test 'doc/*.txt'
    : ok 'doc/notes.txt'
    : no 'doc/server/arch.txt'

test {'*.a','!lib.a'}
    : no 'lib.a'

test '{**/*.html, **/*.txt}'
    : ok '1.html'
    : ok '1.txt'
    : ok 'a/b.html'
    : ok 'a/b.txt'
    : no '1.lua'

test 'a?b'
    : ok 'acb'
    : no 'ab'
    : no 'a/b'
    : no 'aaab'
    : no 'abbb'

test 'example.[0-9]'
    : ok 'example.0'
    : ok 'example.5'
    : no 'example.'
    : no 'example.a'
    : no 'example.10'

test 'example.[0-9a-z]'
    : ok 'example.0'
    : ok 'example.5'
    : ok 'example.a'
    : no 'example.'
    : no 'example.10'

test 'example.[0-9az]'
    : ok 'example.0'
    : ok 'example.5'
    : ok 'example.a'
    : no 'example.'
    : no 'example.10'

test {'src', '!*.dll'}
    : op 'ignoreCase'
    : ok 'Src/main.lua'
    : no 'Src/lpeg.dll'

test 'example.\\[0-9az\\]'
    : no 'example.0'
    : no 'example.5'
    : no 'example.a'
    : no 'example.'
    : no 'example.10'
    : ok 'example.[0-9az]'

test '*.lua.txt'
    : ok '/mnt/d/1.lua.txt'

test '*.lua.txt'
    : ok [[D:\github\test\a.lua.txt]]

-- test {
--     'src',
--     '!*.dll',
--     'lua/hello.lua',
--     'lua/PUB_*.lua',
--     'lua/PUB_',
--     'lua/PUB_*',
--     'aaa/bbb_ccc.lua',
--     'lua/pub2_*.lua',
--     'aaBBccDD.lua',
-- }
--     : op 'ignoreCase'
--     : ok 'Src/main.lua'
--     : no 'Src/lpeg.dll'
--     : ok 'lua/hello.lua'
--     : ok 'lua/PUB_Settings.lua'
--     : ok 'lua/PUB_'
--     : ok 'lua/PUB_111'
--     : ok 'aaa/bbb_ccc.lua'
--     : ok 'lua/pub2_bbb.lua'
--     : ok 'aaBBccDD.lua'
