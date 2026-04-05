fx_version 'cerulean'
game 'gta5'

author 'Flake'
description 'FiveM Physical Therapy Script'
version '1.0.0'
lua54 'yes'

shared_script 'config.lua'

client_script 'client/main.lua'
server_script 'server/main.lua'

dependencies {
    'ox_lib',
    'wasabi_crutch',
    'es_extended'
}


escrow_ignore {
    'config.lua'
}