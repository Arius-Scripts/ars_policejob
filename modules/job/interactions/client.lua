player.interactions = {}

if not Config.Interactions.enable then return end

local IsPedFatallyInjured      = IsPedFatallyInjured
local IsPedCuffed              = IsPedCuffed
local IsEntityPlayingAnim      = IsEntityPlayingAnim
local IsPedArmed               = IsPedArmed
local TriggerEvent             = TriggerEvent
local GetVehicleDoorAngleRatio = GetVehicleDoorAngleRatio

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

local function isEntityHandCuffed(entity)
	return IsPedCuffed(entity)
		or IsEntityPlayingAnim(entity, 'anim@move_m@prisoner_cuffed', 'idle', 3)
		or IsEntityPlayingAnim(entity, 'mp_arresting', 'idle', 3)
end

local function isEntityHandsUp(entity)
	return IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_base', 3)
		or IsEntityPlayingAnim(entity, 'missminuteman_1ig_2', 'handsup_enter', 3)
		or IsEntityPlayingAnim(entity, 'random@mugging3', 'handsup_standing_base', 3)
end

local function playerInteractions()
	if Config.Interactions.search then
		table.insert(player.interactions, {
			name = 'search_suspect',
			icon = 'fas fa-magnifying-glass',
			label = locale('search_suspect_label'),
			groups = Config.Interactions.jobs,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				utils.debug(("^1search_suspect ^3 Is Target Fragile: %s"):format(isEntityFragile(entity)))
				utils.debug(("^1search_suspect ^3 Are you armed: %s"):format(IsPedArmed(cache.ped, 6)))

				return isEntityFragile(entity) and IsPedArmed(cache.ped, 6) and player.inDuty()
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
				groups = Config.Interactions.jobs,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					local count = exports.ox_inventory:Search('count', Config.ItemCuffs)

					utils.debug("^2handcuff_suspect ^3 Have handcuffs: " .. count)
					utils.debug(("^2handcuff_suspect ^3 Is target handcuffed: %s"):format(not
						isEntityHandCuffed(entity)))
					utils.debug(("^2handcuff_suspect ^3 Does target have hands up: %s"):format(
						isEntityHandsUp(entity)))

					return count > 0 and not isEntityHandCuffed(entity) and isEntityHandsUp(entity) and player.inDuty()
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
				groups = Config.Interactions.jobs,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					utils.debug(("uncuff_suspect Is Target handcuffed: %s"):format(isEntityHandCuffed(entity)))

					return isEntityHandCuffed(entity) and player.inDuty()
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
				groups = Config.Interactions.jobs,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					utils.debug(("^4drag_suspect ^3 Is Target handcuffed: %s"):format(isEntityHandCuffed(entity)))

					return isEntityHandCuffed(entity) and player.inDuty()
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
			groups = Config.Interactions.jobs,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				local playerCoords = cache.coords
				local vehicle, vehicleCoords = lib.getClosestVehicle(playerCoords, 3, false)

				utils.debug(("^5put_suspect_in^3 Is Target handcuffed: %s"):format(isEntityHandCuffed(entity)))
				utils.debug(("^5put_suspect_in^3 Is there a vehicle neaby: %s"):format(vehicle))

				return isEntityHandCuffed(entity) and vehicle and player.inDuty()
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
			groups = Config.Interactions.jobs,
			distance = 3,
			canInteract = function(entity, distance, coords, name)
				return player.inDuty()
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
				groups = Config.Interactions.jobs,
				distance = 3,
				canInteract = function(entity, distance, coords, name)
					utils.debug(("^6arrest_suspect^3 Is Target not handcuffed: %s"):format(not isEntityHandCuffed(entity)))
					utils.debug(("^6arrest_suspect^3 Does target have handsup: %s"):format(isEntityHandsUp(entity)))
					utils.debug(("^6arrest_suspect^3 Are you near the police station: %s"):format(player.nearStation and "yes" or "no"))

					-- return not isEntityHandCuffed(entity) and isEntityHandsUp(entity) and #(cache.coords - station.zone.pos) <= 120
					return not isEntityHandCuffed(entity) and isEntityHandsUp(entity) and player.inDuty() and player.nearStation
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
			groups = Config.Interactions.jobs,
			canInteract = function(entity, distance, coords, name)
				return player.showPutOutOption(entity, coords, doorBone, seatBone) and player.inDuty()
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
		groups = Config.Interactions.jobs,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and not player.isPlacingProp and player.inDuty()
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
		groups = Config.Interactions.jobs,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and not player.isPlacingProp and player.inDuty()
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
		groups = Config.Interactions.jobs,
		canInteract = function(entity, distance, coords, name)
			return GetVehicleDoorAngleRatio(entity, 5) > 0.0 and player.isPoliceVehicle(entity) and not player.isPlacingProp and player.inDuty()
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
