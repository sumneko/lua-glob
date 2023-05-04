package.path = '?/init.lua;' .. package.path

print 'Test start.'

require 'test.utility'
require 'test.glob'
require 'test.gitignore'

print 'Test done.'
