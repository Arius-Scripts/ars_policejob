--#--
--Fx info--
--#--
fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'
version '1.0.4'

--#--
--Manifest--
--#--

client_scripts {
	"modules/utils/client/utils.lua",
	'client.lua',

	"modules/compatibility/frameworks/**/client.lua",

	'modules/menu/client/main.lua',
	'modules/menu/client/menus.lua',


	'modules/actions/client/clothing.lua',
	'modules/actions/client/armory.lua',
	'modules/actions/client/garage.lua',
	'modules/actions/client/interdict_area.lua',
	'modules/actions/client/stashes.lua',
	'modules/actions/client/cameras.lua',
	'modules/actions/client/bossmenu.lua',
	'modules/actions/client/duty.lua',

	'modules/interactions/client.lua',
	'modules/interactions/drag/client.lua',
	'modules/interactions/handcuffs/client.lua',
	'modules/interactions/fine/client.lua',
	'modules/interactions/escort/client.lua',
	'modules/interactions/props/client.lua',
	'modules/items/**/client.lua',
}

server_scripts {
	'server.lua',
	'modules/menu/server.lua',
	'modules/interactions/**/server.lua',
	"modules/compatibility/frameworks/**/server.lua",
}

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
}

files {
	'locales/*.json',
}

dependencies {
	'ox_inventory',
	'ox_lib',
	"ox_target"
}

provides {
	"esx_policejob",
	"qb-policejob"
}
