local glob = require 'glob'

local EXISTS = {}

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

local function getPath(root, path)
    local current = root
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

local function test(gitignore)
    return function (root)
        local pattern = {}
        for line in gitignore:gmatch '[^\r\n]+' do
            pattern[#pattern+1] = line
        end
        ---@type gitignore
        local session = glob.gitignore(pattern)
        session:setInterface('type', function (path)
            local current = getPath(root, path)
            if type(current) == 'boolean' then
                return 'file'
            elseif type(current) == 'table' then
                return 'directory'
            end
            return nil
        end)
        session:setInterface('list', function (path)
            local current = getPath(root, path)
            if type(current) == 'table' then
                local childs = {}
                for name in pairs(current) do
                    childs[#childs+1] = path .. '/' .. name
                end
                table.sort(childs)
                return childs
            end
            return nil
        end)

        local result = {}
        session:scan(function (path)
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

        local expect = buildExpect(root)
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
