if not Config.Interactions.enable or not Config.Interactions.put_out_vehicle then return end

local GetPlayerServerId               = GetPlayerServerId
local NetworkGetPlayerIndexFromPed    = NetworkGetPlayerIndexFromPed
local TriggerServerEvent              = TriggerServerEvent
local RegisterNetEvent                = RegisterNetEvent
local GetVehicleMaxNumberOfPassengers = GetVehicleMaxNumberOfPassengers
local IsVehicleSeatFree               = IsVehicleSeatFree
local TaskWarpPedIntoVehicle          = TaskWarpPedIntoVehicle
local GetVehicleDoorLockStatus        = GetVehicleDoorLockStatus
local GetEntityBoneIndexByName        = GetEntityBoneIndexByName
local GetEntityBonePosition_2         = GetEntityBonePosition_2
local TaskLeaveVehicle                = TaskLeaveVehicle

function player.putInVehicle(target)
    local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))
    TriggerServerEvent('ars_policejob:putInVehicle', targetServerId)
end

RegisterNetEvent('ars_policejob:putInVehicle', function()
    local playerPed = cache.ped
    local playerCoords = cache.coords
    local vehicle, vehicleCoords = lib.getClosestVehicle(playerCoords, 3, false)


    if not vehicle then return end

    local maxSeats, freeSeat = GetVehicleMaxNumberOfPassengers(vehicle)
    for i = maxSeats - 1, 0, -1 do
        if IsVehicleSeatFree(vehicle, i) then
            freeSeat = i
            break
        end
    end
    if freeSeat then
        TaskWarpPedIntoVehicle(playerPed, vehicle, freeSeat)
        player.isDragged = false
    end
end)


function player.showPutOutOption(vehicle, coords, door, seat)
    local target = lib.getClosestPlayer(coords, 2, false)

    if not target then return false end

    if GetVehicleDoorLockStatus(vehicle) > 1 then return false end
    local boneId = GetEntityBoneIndexByName(vehicle, door)

    if boneId ~= -1 then
        return #(coords - GetEntityBonePosition_2(vehicle, boneId)) < 0.5 or
            #(coords - GetEntityBonePosition_2(vehicle, GetEntityBoneIndexByName(vehicle, seat))) < 0.72
    end
end

function player.takeOutFromVehicle(coords)
    local target = lib.getClosestPlayer(coords, 3, false)

    if not target then return end

    local targetServerId = GetPlayerServerId(target)

    TriggerServerEvent('ars_policejob:putOutVehicle', targetServerId)
end

RegisterNetEvent('ars_policejob:putOutVehicle', function()
    local playerPed = cache.ped
    local playerVehicle = cache.vehicle

    if not playerVehicle then return end

    TaskLeaveVehicle(playerPed, playerVehicle, 0)
end)
