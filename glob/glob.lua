local m = require 'lpeglabel'

local function prop(name, pat)
    return m.Cg(m.Cc(true), name) * pat
end

local function object(type, pat)
    return m.Ct(
        m.Cg(m.Cc(type), 'type') *
        m.Cg(pat, 'value')
    )
end

local function expect(p, err)
    return p + m.T(err)
end

local parser = m.P {
    'Main',
    ['Sp']          = m.S(' \t')^0,
    ['Slash']       = m.S('/\\')^1,
    ['Main']        = m.Ct(m.P'{' * m.P'Pattern' * (',' * m.V'Pattern')^0 * m.P'}')
                    + m.Ct(m.V'Pattern')
                    + m.T'Main Failed'
                    ,
    ['Pattern']     = m.V'Sp' * m.Ct(prop('neg', m.P'!') * expect(m.V'Unit', 'Miss exp after "!"'))
                    + m.Ct(m.V'Unit')
                    ,
    ['NeedRoot']    = prop('root', (m.P'.' * m.V'Slash' + m.V'Slash')),
    ['Unit']        = m.V'Sp' * m.V'NeedRoot'^-1 * expect(m.V'Exp', 'Miss exp') * m.V'Sp',
    ['Exp']         = m.V'Sp' * (m.V'Symbol' + m.V'Word')^0 * m.V'Sp',
    ['Word']        = object('word', (1 - m.V'Symbol')^1),
    ['Symbol']      = object('**', m.P'**')
                    + object('*',  m.P'*')
                    + object('?',  m.P'?')
                    + object('[]', m.V'Range')
                    ,
    ['Range']       = m.P'[' * m.Ct(prop('range', m.V'RangeUnit'^0)) * m.P']',
    ['RangeUnit']   = m.Ct(- m.P']' * m.C(m.P(1)) * (m.P'-' * - m.P']' * m.C(m.P(1)))^-1),
}

local mt = {}
mt.__index = mt
mt.__name = 'glob'

local function copyTable(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

function mt:addPattern(pat)
    local state, err = parser:match(pat)
    print(state and table.dump(state) or err)
end

function mt:parsePattern()
    for _, pat in ipairs(self.pattern) do
        self:addPattern(pat)
    end
end

return function (pattern, options)
    local self = setmetatable({
        pattern = copyTable(pattern or {}),
        options = copyTable(options or {}),
    }, mt)
    self:parsePattern()
    return self
end
