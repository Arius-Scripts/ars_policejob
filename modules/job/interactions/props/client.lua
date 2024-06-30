local DeleteEntity                = DeleteEntity
local GetEntityCoords             = GetEntityCoords
local GetEntityHeading            = GetEntityHeading
local GetEntityModel              = GetEntityModel
local CreateObject                = CreateObject
local PlaceObjectOnGroundProperly = PlaceObjectOnGroundProperly
local SetEntityHeading            = SetEntityHeading
local GetHeadingFromVector_2d     = GetHeadingFromVector_2d
local GetVehicleClass             = GetVehicleClass
local GetVehicleClassFromName     = GetVehicleClassFromName
local SetEntityAlpha              = SetEntityAlpha
local SetEntityCollision          = SetEntityCollision
local FreezeEntityPosition        = FreezeEntityPosition
local SetModelAsNoLongerNeeded    = SetModelAsNoLongerNeeded
local GetClosestObjectOfType      = GetClosestObjectOfType
local DoesEntityExist             = DoesEntityExist
local SetVehicleTyreBurst         = SetVehicleTyreBurst
local Wait                        = Wait
local CreateThread                = CreateThread
local GetCurrentResourceName      = GetCurrentResourceName

player.isPlacingProp              = false

local function deleteProp(placingProp)
    DeleteEntity(placingProp)
    lib.hideTextUI()
    player.isPlacingProp = false
end

local function placeProp(prop)
    if lib.progressBar({
            duration = 600,
            label = locale("placing_prop_label"),
            useWhileDead = false,
            canCancel = false,
            disable = {
                car = true,
                move = true,
                combat = true
            },
            anim = {
                dict = 'pickup_object',
                clip = 'pickup_low'
            },
        })
    then
        local propCoords = GetEntityCoords(prop)
        local propHeading = GetEntityHeading(prop)
        local model = GetEntityModel(prop)

        DeleteEntity(prop)

        local placedProp = CreateObject(model, propCoords, true, true, true)
        PlaceObjectOnGroundProperly(placedProp)
        SetEntityHeading(placedProp, propHeading)

        player.spawnProp(model)

        exports.ox_target:addLocalEntity(placedProp, {
            {
                name = 'placed_prop' .. placedProp,
                label = 'Pick up',
                distance = 1.5,
                groups = Config.Interactions.jobs,
                canInteract = function(entity, distance, coords, name)
                    return not player.isPlacingProp
                end,
                onSelect = function(data)
                    local playerCoords = cache.coords
                    local heading = GetHeadingFromVector_2d(propCoords.x - playerCoords.x, propCoords.y - playerCoords.y)

                    SetEntityHeading(cache.ped, heading)

                    if lib.progressBar({
                            duration = 600,
                            label = locale("picking_up_prop_label"),
                            useWhileDead = false,
                            canCancel = false,
                            disable = {
                                car = true,
                                move = true,
                                combat = true
                            },
                            anim = {
                                dict = 'pickup_object',
                                clip = 'pickup_low'
                            },
                        })
                    then
                        DeleteEntity(data.entity)
                    end
                end
            }
        })
    end

    lib.hideTextUI()
end


function player.isPoliceVehicle(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)

    for index, model in pairs(Config.PoliceVehicles) do
        if joaat(model) == vehicleModel or GetVehicleClassFromName(model) == vehicleClass then return true end
    end

    return false
end

function player.spawnProp(prop)
    local model = lib.requestModel(prop)
    if not model then return end

    local playerCoords = cache.coords
    player.isPlacingProp = true

    local placingProp = CreateObject(model, playerCoords, false, true, true)
    SetEntityAlpha(placingProp, 170, false)
    SetEntityCollision(placingProp, false, false)
    FreezeEntityPosition(placingProp, true)
    SetModelAsNoLongerNeeded(model)

    lib.showTextUI(locale("placing_prop_instructions"),
        {
            position = 'right-center',
            style = {
                borderRadius = 5,
                backgroundColor = '#212529',
                color = '#F8F9FA',
            },
        })

    while player.isPlacingProp do
        local hit, entityHit, coords, surface, hash = lib.raycast.cam(1, 7, 15)
        if not hit then return end

        SetEntityCoords(placingProp, coords)
        PlaceObjectOnGroundProperly(placingProp)
        DisableControlAction(0, 24, true)

        local placingPropHeading = GetEntityHeading(placingProp)
        if IsControlPressed(0, 38) then
            SetEntityHeading(placingProp, placingPropHeading + 1)
        end

        if IsControlPressed(0, 44) then
            SetEntityHeading(placingProp, placingPropHeading - 1)
        end

        if IsControlJustPressed(0, 177) then
            deleteProp(placingProp)
            player.isPlacingProp = false
            break
        end

        if IsControlJustPressed(0, 18) then
            placeProp(placingProp)
            break
        end

        Wait(0)
    end
end

CreateThread(function()
    while true do
        local sleep = 1500
        local playerVehicle = cache.vehicle
        if playerVehicle then
            local playerCoords = cache.coords
            local object = GetClosestObjectOfType(playerCoords, 50.0, joaat('p_ld_stinger_s'), false, false, false)

            if DoesEntityExist(object) then
                sleep = 500

                local objectCoords = GetEntityCoords(object)
                local distance = #(cache.coords - objectCoords)
                if distance <= 3 then
                    for i = 0, 7, 1 do
                        SetVehicleTyreBurst(playerVehicle, i, true, 1000)
                        Wait(500)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    deleteProp()
end)

exports('isPlacingProp', function()
    return player.isPlacingProp
end)
