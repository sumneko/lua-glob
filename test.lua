require 'utility'
local glob = require 'glob'

local function test(patternStr)
    local pattern = {}
    for l in patternStr:gmatch '[^\r\n]+' do
        pattern[#pattern+1] = l
    end
    glob.glob(pattern)
end

test [[
example
]]
