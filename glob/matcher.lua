local m = require 'lpeglabel'

local slash = m.S('/\\')^1
local path  = (1 - slash)^1 * slash
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
    local current
    local after = self:exp(state, index + 1)
    if exp.type == 'word' then
        current = m.P(exp.value)
    end
    if after then
        return current * after
    else
        return current
    end
end

function mt:anyPath(state, index)
    return m.P {
        'Main',
        Main    = self:exp(state, index)
                + path * m.V'Main'
    }
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
