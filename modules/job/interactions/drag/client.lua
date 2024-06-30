if not Config.Interactions.enable or not Config.Interactions.escort then return end

local IsControlJustReleased        = IsControlJustReleased
local ClearPedTasks                = ClearPedTasks
local TriggerServerEvent           = TriggerServerEvent
local Wait                         = Wait
local GetPlayerServerId            = GetPlayerServerId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local TaskPlayAnim                 = TaskPlayAnim
local GetPlayerPed                 = GetPlayerPed
local GetPlayerFromServerId        = GetPlayerFromServerId
local IsPedSittingInAnyVehicle     = IsPedSittingInAnyVehicle
local AttachEntityToEntity         = AttachEntityToEntity
local DetachEntity                 = DetachEntity
local IsPedDeadOrDying             = IsPedDeadOrDying
local RegisterNetEvent             = RegisterNetEvent

player.isDragged                   = false
player.isDragging                  = false

local function pressToUnDrag(target)
	player.isDragging = true

	local textUi = false

	while player.isDragging do
		utils.debug("Dragging suspect")
		if not textUi then
			textUi = true
			lib.showTextUI(locale('stop_dragging'), {
				position = 'top-center',
				icon = 'hand',
				style = {
					borderRadius = 5,
					backgroundColor = '#212529',
					color = '#F8F9FA',
				},
			})
		end

		if IsControlJustReleased(0, 177) then
			local playerPed = cache.ped
			ClearPedTasks(playerPed)

			TriggerServerEvent('ars_policejob:drag', target)
			player.isDragging = false

			lib.hideTextUI()
			textUi = false
		end

		Wait(1)
	end
end

function player.drag(target)
	local playerPed = cache.ped
	local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))
	local animDict = lib.requestAnimDict('switch@trevor@escorted_out')

	TaskPlayAnim(playerPed, animDict, '001215_02_trvs_12_escorted_out_idle_guard2', 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	TriggerServerEvent('ars_policejob:drag', targetServerId)

	Wait(500)
	pressToUnDrag(targetServerId)
end

RegisterNetEvent('ars_policejob:drag', function(playerid)
	player.isDragged = not player.isDragged

	local playerPed = cache.ped
	local targetPed = GetPlayerPed(GetPlayerFromServerId(playerid))
	while player.isDragged do
		if player.cuffed then
			if not IsPedSittingInAnyVehicle(targetPed) then
				AttachEntityToEntity(playerPed, targetPed, 23639, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false,
					false, 2, true)
			else
				player.isDragged = false
				DetachEntity(playerPed, true, false)
			end
			if IsPedDeadOrDying(targetPed, true) then
				player.isDragged = false
				DetachEntity(playerPed, true, false)
			end
		end
		Wait(1)
	end
	DetachEntity(playerPed, true, false)
end)

exports('isDragged', function()
	return player.isDragged
end)
exports('isDragging', function()
	return player.isDragging
end)
