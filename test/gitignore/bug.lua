local glob = require 'glob'

do
    local session = glob.gitignore()
    session:setInterface('type', function (path)
        return 'directory'
    end)
    session:setInterface('list', function (path)
        return {
            '.',
            '/.',
            './',
            '/./',
        }
    end)
    session:scan()
end
