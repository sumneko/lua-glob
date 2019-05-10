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
    self.matcher:setInterface('fileType', func)
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

test 'src/'
    : ft(function (_, path)
        if path == 'a/src' then
            return 'file'
        else
            return 'directory'
        end
    end)
    : ok 'src/a'
    : no 'a/src'

test 'src/'
    : ft(function (_, path)
        return 'directory'
    end)
    : ok 'src/a'
    : ok 'a/src'

test 'src/'
    : ft(function (_, path)
        return 'file'
    end)
    : ok 'src/a'
    : no 'a/src'

test {'aaa', '!aaa/bbb'}
    : ft(function (_, path)
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
    : ft(function (_, path)
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
    : ft(function (_, path)
        if path == 'aaa' then
            return 'directory'
        else
            return 'file'
        end
    end)
    : no 'aaa'
    : no 'aaa/bbb'
    : ok 'aaa/ccc'
