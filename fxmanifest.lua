fx_version 'cerulean'
game 'gta5'
lua54 'yes'
description 'Shop UI for FiveM'
author 'Cs0ng0r'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/index.js',
}
