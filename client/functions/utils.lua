local CreatePed = CreatePed
local FreezeEntityPosition = FreezeEntityPosition
local SetEntityInvincible = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local SetModelAsNoLongerNeeded = SetModelAsNoLongerNeeded
local RegisterNetEvent = RegisterNetEvent


utils = {}
peds = {}

function utils.createPed(name, coords)
    local model = lib.requestModel(name)

    if not model then return end

    local ped = CreatePed(0, model, coords, false, false)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(model)

    table.insert(peds, ped)

    return ped
end

function utils.showNotification(msg, type)
    lib.notify({
        title = 'Ars Policejob',
        description = msg,
        type = type and type or 'info'
    })
end

RegisterNetEvent('ars_policejob:showNotification', utils.showNotification)
