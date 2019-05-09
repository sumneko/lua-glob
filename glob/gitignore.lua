local glob = require 'glob.glob'

local mt = {}
mt.__index = mt
mt.__name = 'gitignore'

function mt:addPattern(pat)
    return self.parser:addPattern(pat)
end

function mt:setOption(op, val)
    return self.parser:setOption(op, val)
end

function mt:addMethod(key, func)
    if type(func) ~= 'function' then
        return
    end
    self.method[key] = func
end

function mt:__call(path)
    if self.method.isDirectory then
        local isDirectory = self.method.isDirectory(path)
        return self.parser(path, function (matcher)
            if matcher:isNeedDirectory() then
                return isDirectory == true
            end
            return true
        end)
    else
        return self.parser(path)
    end
end

return function (pattern, options, methods)
    local parser = glob(pattern, options)
    local self = setmetatable({
        parser = parser,
        errors = parser.errors,
        method = {},
    }, mt)

    if type(methods) == 'table' then
        for key, func in pairs(methods) do
            self:addMethod(key, func)
        end
    end

    return self
end
