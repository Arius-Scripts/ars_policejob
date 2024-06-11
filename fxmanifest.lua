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
	'client/functions/utils.lua',
	'client/client.lua',

	'client/bridge/esx.lua',
	'client/bridge/qb.lua',

	'client/menu/main.lua',
	'client/menu/menus.lua',


	'client/clothing.lua',
	'client/armory.lua',
	'client/garage.lua',
	'client/interdict_area.lua',
	'client/stashes.lua',
	'client/cameras.lua',
	'client/bossmenu.lua',
	'client/duty.lua',

	'client/interaction/interaction.lua',
	'client/interaction/drag.lua',
	'client/interaction/handcuffs.lua',
	'client/interaction/fine.lua',
	'client/interaction/in_out_vehicle.lua',
	'client/interaction/props.lua',
	'client/items/*.lua',
}

server_scripts {
	'server/server.lua',
	'server/menu/main.lua',
	'server/interaction/*.lua',
	'server/bridge/esx.lua',
	'server/bridge/qb.lua',
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
