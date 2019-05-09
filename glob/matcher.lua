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
        return self:word(exp, state, index + 1)
    elseif exp.type == 'char' then
        return self:char(exp, state, index + 1)
    elseif exp.type == '**' then
        return self:anyPath(exp, state, index + 1)
    elseif exp.type == '*' then
        return self:anyChar(exp, state, index + 1)
    elseif exp.type == '?' then
        return self:oneChar(exp, state, index + 1)
    elseif exp.type == '[]' then
    end
end

function mt:word(exp, state, index)
    local current = self:exp(exp.value, 1)
    local after = self:exp(state, index)
    if after then
        return current * Slash * after
    else
        return current
    end
end

function mt:char(exp, state, index)
    local current = m.P(exp.value)
    local after = self:exp(state, index)
    if after then
        return current * after * NoWord
    else
        return current * NoWord
    end
end

function mt:anyPath(_, state, index)
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

function mt:anyChar(_, state, index)
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

function mt:oneChar(_, state, index)
    local after = self:exp(state, index)
    if after then
        return Char * after
    else
        return Char
    end
end

function mt:pattern(state)
    if state.root then
        return m.C(self:exp(state, 1))
    else
        return m.C(self:anyPath(nil, state, 1))
    end
end

return function (state, options)
    local self = setmetatable({
        options = options,
    }, mt)
    local matcher = self:pattern(state)
    return matcher
end
