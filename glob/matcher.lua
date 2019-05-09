local m = require 'lpeglabel'

local Slash  = m.S('/\\')^1
local Symbol = m.S',{}[]*?/\\'
local Char   = 1 - Symbol
local Path   = Char^1 * Slash
local NoWord = #(m.P(-1) + Symbol)
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
        local current = self:exp(exp.value, 1)
        local after = self:exp(state, index + 1)
        if after then
            return current * Slash * after
        else
            return current
        end
    elseif exp.type == 'char' then
        local current = m.P(exp.value)
        local after = self:exp(state, index + 1)
        if after then
            return current * after * NoWord
        else
            return current * NoWord
        end
    elseif exp.type == '**' then
        return self:anyPath(state, index + 1)
    elseif exp.type == '*' then
        return self:anyChar(state, index + 1)
    end
end

function mt:anyPath(state, index)
    local after = self:exp(state, index)
    if after then
        return m.P {
            'Main',
            Main    = after
                    + Path * m.V'Main'
        }
    else
        return Path^0
    end
end

function mt:anyChar(state, index)
    local after = self:exp(state, index)
    if after then
        return m.P {
            'Main',
            Main    = after
                    + Char * m.V'Main'
        }
    else
        return Char^0
    end
end

function mt:pattern(state)
    if state.root then
        return m.C(self:exp(state, 1))
    else
        return m.C(self:anyPath(state, 1))
    end
end

return function (state, options)
    local self = setmetatable({
        options = options,
    }, mt)
    local matcher = self:pattern(state)
    return matcher
end
