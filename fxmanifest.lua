fx_version 'adamant'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

description 'shops for VoRP whith UI. Based on Vorp_store'
author 'Cruso#5040'

shared_scripts {
  'config.lua'
}

client_scripts {
  'client/*.lua',
  
}

server_scripts {
  'server.lua',
}

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/scripts/*.js',
	'html/img/*.png',
	'html/img/shop/*.png',
	'html/img/shop/category/*.png',
	'html/img/shop/items/*.png',
	'html/css/*.css',
	'html/fonts/*.ttf',
	
}




