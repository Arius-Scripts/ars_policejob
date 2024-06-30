-- temp fix
local function convertGroupsToStashFormat(groupsArray, minGrade)
    local stashGroups = {}
    for _, groupName in ipairs(groupsArray) do
        stashGroups[groupName] = minGrade or 0
    end
    return stashGroups
end


CreateThread(function()
    for index, station in pairs(Config.PoliceStations) do
        local cfg = station

        if cfg.armory.require_storage then
            local armory = cfg.armory.storage
            exports.ox_inventory:RegisterStash(armory.stashId, armory.stashLabel, 500, 1000 * 1000, nil, convertGroupsToStashFormat(station.jobs, armory.minGradeAccess), nil)
            -- print(("^3DEBUG: %s ^7"):format("Armory stash registered " .. armory.stashId))
        end

        for id, stash in pairs(cfg.stash) do
            exports.ox_inventory:RegisterStash(id, stash.label, stash.slots, stash.weight * 1000, cfg.stash.shared and true or nil, convertGroupsToStashFormat(station.jobs), stash.pos)
            -- print(("^3DEBUG: %s ^7"):format("Stash registered " .. id))
        end
    end
end)

lib.callback.register('ars_policejob:getItemCount', function(source, stash, item)
    local inventory = stash

    local items = exports.ox_inventory:Search(inventory, 'count', item)

    return items
end)

RegisterNetEvent('ars_policejob:giveItemToPlayer', function(stash, item, quantity, storage, jobs)
    if not hasJob(source, jobs) or not source or source < 1 then return end

    exports.ox_inventory:AddItem(source, item, quantity)

    if storage then
        exports.ox_inventory:RemoveItem(stash, item, quantity)
    end
end)

RegisterNetEvent('ars_policejob:activateBlip', function(data)
    if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

    TriggerClientEvent('ars_policejob:activateBlip', -1, data)
end)

RegisterNetEvent('ars_policejob:createEmergencyBlip', function(data)
    if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

    TriggerClientEvent('ars_policejob:createEmergencyBlip', -1, data)
end)


RegisterNetEvent("ars_policejob:updateDuty", function(value)
    local source = source
    local playerIdentifier = GetPlayerIdentifierByType(source, "license")
    SetResourceKvpInt("policejob_duty:" .. playerIdentifier, value == true and 1 or 0)
    TriggerClientEvent("ars_policejob:dutyStatusUpdated", source, value)
end)

lib.callback.register('ars_policejob:getDutyStatus', function(source)
    local playerIdentifier = GetPlayerIdentifierByType(source, "license")
    local value = GetResourceKvpInt("policejob_duty:" .. playerIdentifier)

    return value == 1 and true or false
end)

lib.versionCheck('Arius-Development/ars_policejob')
