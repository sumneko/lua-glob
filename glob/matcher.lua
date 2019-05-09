local m = require 'lpeglabel'

local slash = m.S('/\\')^1
local path  =  (1 - slash)^1
local function whatHappened()
    return m.Cmt(m.P(1)^1, function (...)
        print(...)
    end)
end

local mt = {}
mt.__index = mt
mt.__name = 'matcher'

function mt:exp(state, index)
    local exp = state[index]
    if not exp then
        return
    end
    if exp.type == 'word' then
        local current = m.P(exp.value)
        local after = self:exp(state, index + 1)
        if after then
            return current * slash * after
        else
            return current
        end
    elseif exp.type == '**' then
        return self:anyPath(state, index + 1)
    end
end

function mt:anyPath(state, index)
    local after = self:exp(state, index)
    if after then
        return m.P {
            'Main',
            Main    = after
                    + path * slash * m.V'Main'
        }
    else
        return path^0
    end
end

function mt:pattern(state)
    if state.root then
        return self:exp(state, 1)
    else
        return self:anyPath(state, 1)
    end
end

return function (state, options)
    local self = setmetatable({
        options = options,
    }, mt)
    local matcher = self:pattern(state)
    return matcher
end
