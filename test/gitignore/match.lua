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

function mt:ft(func)
    self.matcher:setInterface('type', func)
    return self
end

local function test(pattern, options)
    local matcher = glob.gitignore(pattern, options)
    return setmetatable({
        matcher = matcher
    }, mt)
end

print 'Test gitignore ...'
test 'src/'
    : ok 'src/a'
    : ok 'a/src'

test 'example.[0-9az]'
    : ok 'example.0'
    : ok 'example.5'
    : ok 'example.a'
    : ok 'example.z'
    : no 'example.'
    : no 'example.10'

test 'example.[a0-9z]'
    : ok 'example.0'
    : ok 'example.5'
    : ok 'example.a'
    : ok 'example.z'
    : no 'example.'
    : no 'example.10'

test 'example.\\[a0-9z\\]'
    : no 'example.0'
    : no 'example.5'
    : no 'example.a'
    : no 'example.z'
    : no 'example.'
    : no 'example.10'
    : ok 'example.[a0-9z]'

test 'src/'
    : ft(function (path)
        if path == 'a/src' then
            return 'file'
        else
            return 'directory'
        end
    end)
    : ok 'src/a'
    : no 'a/src'

test 'src/'
    : ft(function (path)
        return 'directory'
    end)
    : ok 'src/a'
    : ok 'a/src'

test 'src/'
    : ft(function (path)
        return 'file'
    end)
    : ok 'src/a'
    : no 'a/src'

test {'aaa', '!aaa/bbb'}
    : ft(function (path)
        if path == 'aaa' then
            return 'directory'
        else
            return 'file'
        end
    end)
    : ok 'aaa'
    : ok 'aaa/bbb'
    : ok 'aaa/ccc'

test {'aaa/', '!aaa/bbb'}
    : ft(function (path)
        if path == 'aaa' then
            return 'directory'
        else
            return 'file'
        end
    end)
    : ok 'aaa'
    : ok 'aaa/bbb'
    : ok 'aaa/ccc'

test {'aaa/*', '!aaa/bbb'}
    : ft(function (path)
        if path == 'aaa' then
            return 'directory'
        else
            return 'file'
        end
    end)
    : no 'aaa'
    : no 'aaa/bbb'
    : ok 'aaa/ccc'

test {'/*', '!/usr'}
    : ft(function (path)
        if path == 'usr' then
            return 'directory'
        else
            return 'file'
        end
    end)
    : ok 'a.lua'
    : no 'usr/a.lua'

test '/'
    : no '1'
    : no '2/1'