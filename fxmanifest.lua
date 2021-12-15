fx_version 'cerulean'
game 'gta5'

author 'TrAsKiN'
description 'Customizable vehicle management'

lua54 'yes'

files {
    'locale/*.json',
    'data/vehicleHandlings.json',
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
