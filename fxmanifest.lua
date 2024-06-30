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
	"modules/utils/client.lua",
	'client.lua',

	"modules/compatibility/frameworks/**/client.lua",

	'modules/job/menu/client/main.lua',
	'modules/job/menu/client/menus.lua',


	'modules/job/actions/client/clothing.lua',
	'modules/job/actions/client/armory.lua',
	'modules/job/actions/client/garage.lua',
	'modules/job/actions/client/interdict_area.lua',
	'modules/job/actions/client/stashes.lua',
	'modules/job/actions/client/cameras.lua',
	'modules/job/actions/client/bossmenu.lua',
	'modules/job/actions/client/duty.lua',

	'modules/job/interactions/client.lua',
	'modules/job/interactions/drag/client.lua',
	'modules/job/interactions/handcuffs/client.lua',
	'modules/job/interactions/fine/client.lua',
	'modules/job/interactions/escort/client.lua',
	'modules/job/interactions/props/client.lua',
	'modules/job/items/**/client.lua',
}

server_scripts {
	'server.lua',
	'modules/job/menu/server.lua',
	'modules/job/interactions/**/server.lua',
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
