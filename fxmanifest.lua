fx_version 'cerulean'
game 'gta5'

author 'TrAsKiN'
description 'Customizable vehicle management for FiveM'

lua54 'yes'

dependencies {}

files {
    'locale/*.json',
    'data/*.json',
}

shared_scripts {
    'shared/logger.lua',
}

client_scripts {
    'client/manager.lua',
    'client/blinkers.lua',
    'client/doors.lua',
    'client/ejection.lua',
    'client/engine.lua',
    'client/fuel.lua',
    'client/limiter.lua',
    'client/siren.lua',
    'client/windows.lua',
}

server_scripts {
    'server/manager.lua',
    'server/ejection.lua',
}
