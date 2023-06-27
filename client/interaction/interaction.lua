if not Config.Interactions.enable then return end

local IsPedFatallyInjured      = IsPedFatallyInjured
local IsPedCuffed              = IsPedCuffed
local IsEntityPlayingAnim      = IsEntityPlayingAnim
local IsPedArmed               = IsPedArmed
local TriggerEvent             = TriggerEvent
local GetVehicleDoorAngleRatio = GetVehicleDoorAngleRatio

player                         = {}
player.interactions            = {}

local function isEntityFragile(entity) -- yoinked from ox_inventory
	return IsPedFatallyInjured(entity)
		or IsPedCuffed(entity)
		or IsEntityPlayingAnim(entity, 'dead', 'dead_a', 3)
		or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
		or IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_base', 3)
		or IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_enter', 3)
		or IsEntityPlayingAnim(entity, 'random@mugging3', 'handsup_standing_base', 3)
		or IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3)
		or IsEntityPlayingAnim(entity, 'random@dealgonewrong', 'idle_a', 3)
end

local function playerInteractions()
	if Config.Interactions.search then
		table.insert(player.interactions, {
			name = 'search_suspect',
			icon = 'fas fa-magnifying-glass',
			label = locale('search_suspect_label'),
			groups = Config.PoliceJobName,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				return isEntityFragile(entity) and IsPedArmed(cache.ped, 6)
			end,
			onSelect = function(data)
				exports.ox_inventory:openNearbyInventory()
			end,
		})
	end

	if Config.Interactions.handcuffs then
		table.insert(player.interactions,
			{
				name = 'handcuff_suspect',
				icon = 'fas fa-magnifying-glass',
				label = locale('handcuff_suspect_label'),
				groups = Config.PoliceJobName,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					local count = exports.ox_inventory:Search('count', Config.ItemCuffs)

					return count > 0
						and (not IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3) or not IsEntityPlayingAnim(
							entity,
							'mp_arresting',
							'idle',
							3
						))
						and IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_enter', 3)
				end,
				onSelect = function(data)
					player.handcuff(data.entity)
				end,
			}
		)
		table.insert(player.interactions,
			{
				name = 'uncuff_suspect',
				icon = 'fas fa-magnifying-glass',
				label = locale('uncuff_suspect_label'),
				groups = Config.PoliceJobName,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					return IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3)
						or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
				end,
				onSelect = function(data)
					player.uncuff(data.entity)
				end,
			}
		)
	end

	if Config.Interactions.escort then
		table.insert(player.interactions,
			{
				name = 'drag_suspect',
				icon = 'fas fa-magnifying-glass',
				label = locale('drag_suspect_label'),
				groups = Config.PoliceJobName,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					return (IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3) or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3))
				end,
				onSelect = function(data)
					player.drag(data.entity)
				end,
			}
		)
	end

	if Config.Interactions.put_out_vehicle then
		table.insert(player.interactions, {
			name = 'put_suspect_in',
			icon = 'fas fa-magnifying-glass',
			label = locale('put_suspect_in_vehicle_label'),
			groups = Config.PoliceJobName,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				local playerCoords = cache.coords
				local vehicle, vehicleCoords = lib.getClosestVehicle(playerCoords, 3, false)

				return (IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3) or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)) and
					vehicle
			end,
			onSelect = function(data)
				player.putInVehicle(data.entity)
			end
		})
	end

	if Config.Interactions.fines then
		table.insert(player.interactions, {
			name = 'fine_suspect',
			icon = 'fas fa-magnifying-glass',
			label = locale('fine_suspect_label'),
			groups = Config.PoliceJobName,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				return true
			end,
			onSelect = function(data)
				player.finePlayer(data.entity)
			end
		})
	end

	if Config.Interactions.prison then
		table.insert(player.interactions,
			{

				name = 'arrest_suspect',
				icon = 'fas fa-magnifying-glass',
				label = locale('arrest_suspect_label'),
				groups = Config.PoliceJobName,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					return (not IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3) or not IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)) and
						IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_enter', 3) and
						#(cache.coords - Config.PoliceStation.zone.pos) <= 120
				end,
				onSelect = function(data)
					if Config.PrisonSystem == 'esx-qalle-jail' then
						TriggerEvent('esx-qalle-jail:openJailMenu')
					else
						TriggerEvent('pickle_prisons:jailDialog')
					end
				end,

			}
		)
	end

	exports.ox_target:addGlobalPlayer(player.interactions)
end

local function vehicleInteractions()
	local options = {}

	local function createPutOutOption(doorBone, seatBone)
		table.insert(options, {
			name = 'arius_toglidalveh' .. doorBone,
			icon = 'fa-solid fa-car-side',
			label = locale('take_suspect_out_vehicle_label'),
			bones = { doorBone, seatBone },
			groups = Config.PoliceJobName,
			canInteract = function(entity, distance, coords, name)
				return player.showPutOutOption(entity, coords, doorBone, seatBone)
			end,
			onSelect = function(data)
				player.takeOutFromVehicle(data.coords)
			end
		})
	end

	table.insert(options, {
		name = "arius_placecone",
		icon = 'fa-solid fa-code',
		label = locale("take_cone_label"),
		bones = 'boot',
		groups = Config.PoliceJobName,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and
				not player.isPlacingProp
		end,
		onSelect = function(data)
			player.spawnProp('prop_roadcone02a')
		end
	})
	table.insert(options, {
		name = "arius_place_barrier",
		icon = 'fa-solid fa-road-barrier',
		label = locale("take_barrier_label"),
		bones = 'boot',
		groups = Config.PoliceJobName,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and
				not player.isPlacingProp
		end,
		onSelect = function(data)
			player.spawnProp('prop_barrier_work05')
		end
	})
	table.insert(options, {
		name = "arius_place_spikestrips",
		icon = 'fa-solid fa-road-spikes',
		label = locale("take_spikestrips_label"),
		bones = 'boot',
		groups = Config.PoliceJobName,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and
				not player.isPlacingProp
		end,
		onSelect = function(data)
			player.spawnProp('p_ld_stinger_s')
		end
	})

	if Config.Interactions.put_out_vehicle then
		createPutOutOption('door_dside_r', 'seat_dside_r')
		createPutOutOption('door_dside_f', 'seat_dside_f')
		createPutOutOption('door_pside_f', 'seat_pside_f')
		createPutOutOption('door_pside_r', 'seat_pside_r')
	end

	exports.ox_target:addGlobalVehicle(options)
end

playerInteractions()
vehicleInteractions()
