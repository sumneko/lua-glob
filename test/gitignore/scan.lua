local glob = require 'glob'

local EXISTS = {}
local GITIGNORE = {}

local function eq(a, b)
    if a == EXISTS and b ~= nil then
        return true
    end
    local tp1, tp2 = type(a), type(b)
    if tp1 ~= tp2 then
        return false
    end
    if tp1 == 'table' then
        local mark = {}
        for k in pairs(a) do
            if not eq(a[k], b[k]) then
                return false
            end
            mark[k] = true
        end
        for k in pairs(b) do
            if not mark[k] then
                return false
            end
        end
        return true
    end
    return a == b
end

local function splitPath(path)
    local result = {}
    for name in path:gmatch '[^/\\]+' do
        result[#result+1] = name
    end
    return result
end

local function getPath(dir, path)
    local current = dir
    for name in path:gmatch '[^/\\]+' do
        current = current[name]
        if current == nil then
            return nil
        end
    end
    return current
end

local function buildExpect(root)
    local result = {}
    for k, v in pairs(root) do
        if type(v) == 'table' then
            result[k] = buildExpect(v)
        elseif v == true then
            result[k] = true
        end
    end
    if not next(result) then
        return nil
    end
    return result
end

local function test(gitignore, root)
    return function (dir)
        local pattern = {}
        for line in gitignore:gmatch '[^\r\n]+' do
            pattern[#pattern+1] = line
        end
        local session = glob.gitignore(pattern)
        if root then
            session:setOption('root', root)
        end
        session:setInterface('type', function (path)
            local current = getPath(dir, path)
            if type(current) == 'boolean' then
                return 'file'
            elseif type(current) == 'table' then
                return 'directory'
            end
            return nil
        end)
        session:setInterface('list', function (path)
            local current = getPath(dir, path)
            if type(current) == 'table' then
                local childs = {}
                for name in pairs(current) do
                    if path == '' then
                        childs[#childs+1] = name
                    else
                        childs[#childs+1] = path .. '/' .. name
                    end
                end
                table.sort(childs)
                return childs
            end
            return nil
        end)

        local result = {}
        session:scan(root or '', function (path)
            local current = result
            local names = splitPath(path)
            for i = 1, #names-1 do
                local name = names[i]
                if not current[name] then
                    current[name] = {}
                end
                current = current[name]
            end
            local name = names[#names]
            current[name] = true
        end)

        local expect = buildExpect(dir)
        assert(eq(expect, result))
    end
end

test [[
*.dll
]]
{
    ['a.lua'] = true,
    ['b.lua'] = true,
    ['c.dll'] = false,
    ['bin'] = {
        ['a.dll'] = false,
        ['b.dll'] = false,
    },
    ['src'] = {
        ['a.lua'] = true,
        ['b.lua'] = true,
        ['c.lua'] = true,
        ['d.dll'] = false,
    }
}

test [[
*.*
!*.lua
]]
{
    ['a.lua'] = true,
    ['b.lua'] = true,
    ['c.dll'] = false,
    ['bin'] = {
        ['a.dll'] = false,
        ['b.dll'] = false,
    },
    ['src'] = {
        ['a.lua'] = true,
        ['b.lua'] = true,
        ['c.lua'] = true,
        ['d.dll'] = false,
    }
}

test [[
/*.dll
]]
{
    ['a.lua'] = true,
    ['b.lua'] = true,
    ['c.dll'] = false,
    ['bin'] = {
        ['a.dll'] = true,
        ['b.dll'] = true,
    },
    ['src'] = {
        ['a.lua'] = true,
        ['b.lua'] = true,
        ['c.lua'] = true,
        ['d.dll'] = true,
    }
}

test [[
src/*
!*.dll
]]
{
    ['a.lua'] = true,
    ['b.lua'] = true,
    ['c.dll'] = true,
    ['bin'] = {
        ['a.dll'] = true,
        ['b.dll'] = true,
    },
    ['src'] = {
        ['a.lua'] = false,
        ['b.lua'] = false,
        ['c.lua'] = false,
        ['d.dll'] = true,
    }
}

test [[
*.lua
!/*.lua
]]
{
    ['a.lua'] = true,
    ['publish'] = {
        ['a.lua'] = false,
    }
}

test([[
/*
!/usr
]], 'root')
{
    ['root'] = {
        ['a.lua'] = false,
        ['usr'] = {
            ['a.lua'] = true,
        }
    }
}

test([[
XXX/YYY
]], 'root')
{
    ['root'] = {
        ['a.lua'] = true,
        ['b.lua'] = true,
        ['XXX'] = {
            ['a.lua'] = true,
            ['b.lua'] = true,
            ['YYY'] = {
                ['a.lua'] = false,
                ['b.lua'] = false,
                ['ZZZ'] = {
                    ['a.lua'] = false,
                    ['b.lua'] = false,
                }
            },
        }
    }
}

test('', 'root')
{
    [GITIGNORE] = {
        'b.lua',
        'ZZZ',
    },
    ['root'] = {
        ['a.lua'] = true,
        ['b.lua'] = false,
        ['c.lua'] = true,
        ['XXX'] = {
            [GITIGNORE] = {
                'a.lua',
            },
            ['a.lua'] = false,
            ['b.lua'] = false,
            ['c.lua'] = true,
            ['YYY'] = {
                ['a.lua'] = false,
                ['b.lua'] = false,
                ['c.lua'] = true,
                ['ZZZ'] = {
                    ['a.lua'] = false,
                    ['b.lua'] = false,
                    ['c.lua'] = true,
                }
            },
        },
        ['YYY'] = {
            ['a.lua'] = true,
            ['b.lua'] = false,
            ['c.lua'] = true,
        },
        ['ZZZ'] = {
            ['a.lua'] = false,
            ['b.lua'] = false,
            ['c.lua'] = false,
        }
    }
}
