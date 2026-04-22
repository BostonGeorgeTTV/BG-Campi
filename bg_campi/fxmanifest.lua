fx_version 'cerulean'
game 'gta5'

author 'BostonGeorgeTTV'
description 'Raccolta illegale'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/utils.lua',
    'server/server.lua'
}

files {
    'stream/coca_plant.ydr',
    'stream/poppy_plant.ydr',
    'stream/bg_prop.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/bg_prop.ytyp'