fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'


description 'infinity-oil-delivery'
version '1.0.0'

shared_scripts {
    'locales/*.lua',
    'config.lua',
}

client_script {
    'client/*.lua',
    'client/progressbar.lua',
    'client/sellitem.lua',
}

server_scripts {
    'server/server.lua',
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/ui.js',
    'html/ui.css',
}

lua54 'yes'