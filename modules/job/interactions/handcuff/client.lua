if not Config.Interactions.enable or not Config.Interactions.handcuffs then return end

local GetEntityHeading                = GetEntityHeading
local TriggerServerEvent              = TriggerServerEvent
local GetPlayerServerId               = GetPlayerServerId
local NetworkGetPlayerIndexFromPed    = NetworkGetPlayerIndexFromPed
local TaskPlayAnim                    = TaskPlayAnim
local Wait                            = Wait
local ClearPedTasks                   = ClearPedTasks
local CreateThread                    = CreateThread
local SetEnableHandcuffs              = SetEnableHandcuffs
local SetPedCanPlayGestureAnims       = SetPedCanPlayGestureAnims
local SetPedPathCanUseLadders         = SetPedPathCanUseLadders
local RegisterNetEvent                = RegisterNetEvent
local SetCurrentPedWeapon             = SetCurrentPedWeapon
local IsEntityPlayingAnim             = IsEntityPlayingAnim
local IsPedRagdoll                    = IsPedRagdoll
local DeleteEntity                    = DeleteEntity
local CreateObject                    = CreateObject
local ObjToNet                        = ObjToNet
local SetNetworkIdExistsOnAllMachines = SetNetworkIdExistsOnAllMachines
local SetNetworkIdCanMigrate          = SetNetworkIdCanMigrate
local NetworkSetNetworkIdDynamic      = NetworkSetNetworkIdDynamic
local AttachEntityToEntity            = AttachEntityToEntity
local GetPedBoneIndex                 = GetPedBoneIndex
local DisableControlAction            = DisableControlAction
local GetCurrentResourceName          = GetCurrentResourceName

player.cuffed                         = false
player.cuffs                          = nil

function player.handcuff(target)
	local playerPed = cache.ped
	local playerHeading = GetEntityHeading(playerPed)
	local targetHeading = GetEntityHeading(target)
	local dist = #(
		vector3(playerHeading, playerHeading, playerHeading) - vector3(targetHeading, targetHeading, targetHeading)
	)
	local handcuffStatus = dist > 200.0 and 1 or 0
	local animDict = lib.requestAnimDict('mp_arresting')

	TriggerServerEvent('ars_policejob:handcuff', {
		handcuffStatus = handcuffStatus,
		targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target)),
	})

	TaskPlayAnim(playerPed, animDict, 'a_uncuff', 8.0, -8, -1, 49, 0, false, false, false)
	Wait(2000)
	ClearPedTasks(playerPed)
end

function player.startAnim(status)
	CreateThread(function()
		local playerPed = cache.ped
		local animDict = status == 0 and 'mp_arresting' or status == 1 and 'anim@move_m@prisoner_cuffed'
		local dict = lib.requestAnimDict(animDict)

		SetEnableHandcuffs(playerPed, true)
		SetPedCanPlayGestureAnims(playerPed, false)
		SetPedPathCanUseLadders(playerPed, false)
		SetCurrentPedWeapon(playerPed, joaat('WEAPON_UNARMED'), true)

		player.cuffed = true

		while player.cuffed do
			sleep = 500
			if not IsEntityPlayingAnim(playerPed, dict, 'idle', 49) or IsPedRagdoll(playerPed) then
				sleep = 1
				TaskPlayAnim(playerPed, dict, 'idle', 8.0, -8, -1, 49, 0, false, false, false)
			end
			Wait(sleep)
		end

		ClearPedTasks(playerPed)
		SetEnableHandcuffs(playerPed, false)
		SetPedCanPlayGestureAnims(playerPed, true)
		SetPedPathCanUseLadders(playerPed, true)
	end)
end

RegisterNetEvent('ars_policejob:handcuff', function(status)
	player.startAnim(status)

	local playerPed = cache.ped
	local playerCoords = cache.coords
	local prop = lib.requestModel('p_cs_cuffs_02_s')

	if player.cuffs then
		DeleteEntity(player.cuffs)
		player.cuffs = nil
	end

	player.cuffs = CreateObject(prop, playerCoords, true, true, true)

	local networkId = ObjToNet(player.cuffs)
	SetNetworkIdExistsOnAllMachines(networkId, true)
	SetNetworkIdCanMigrate(networkId, false)
	NetworkSetNetworkIdDynamic(networkId, true)

	if status == 0 then
		AttachEntityToEntity(
			player.cuffs,
			playerPed,
			GetPedBoneIndex(playerPed, 60309),
			-0.055,
			0.06,
			0.04,
			265.0,
			155.0,
			80.0,
			true,
			false,
			false,
			false,
			0,
			true
		)
	else
		AttachEntityToEntity(
			player.cuffs,
			playerPed,
			GetPedBoneIndex(playerPed, 60309),
			-0.058,
			0.005,
			0.090,
			290.0,
			95.0,
			120.0,
			true,
			false,
			false,
			false,
			0,
			true
		)
	end

	player.disableControls()
end)

function player.uncuff(target)
	local playerPed = cache.ped
	local animDict = lib.requestAnimDict('mp_arresting')

	TaskPlayAnim(playerPed, animDict, 'a_uncuff', 8.0, -8, -1, 49, 0, false, false, false)

	Wait(2000)

	TriggerServerEvent('ars_policejob:uncuff', {
		targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target)),
	})

	ClearPedTasks(playerPed)
end

RegisterNetEvent('ars_policejob:uncuff', function()
	if not player.cuffed then return end
	local playerPed = cache.ped

	SetEnableHandcuffs(playerPed, false)
	SetPedCanPlayGestureAnims(playerPed, true)
	SetPedPathCanUseLadders(playerPed, true)
	ClearPedTasks(playerPed)
	DeleteEntity(player.cuffs)

	player.cuffs = nil
	player.cuffed = false
end)

function player.disableControls()
	CreateThread(function()
		while player.cuffed do
			DisableControlAction(0, 140, true)
			DisableControlAction(0, 69, true)
			DisableControlAction(0, 92, true)
			DisableControlAction(0, 114, true)
			DisableControlAction(0, 56, true)

			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288, true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true) -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true) -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle
			Wait(0)
		end
	end)
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then
		return
	end
	DeleteEntity(player.cuffs)
end)


exports('cuffed', function()
	return player.cuffed
end)
exports('cuffs', function()
	return player.cuffs
end)
