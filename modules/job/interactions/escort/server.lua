RegisterNetEvent('ars_policejob:putInVehicle', function(target)
    if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

    local target = tonumber(target)
    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target)

    if target == -1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        print(source .. ' probible modder')
    else
        TriggerClientEvent('ars_policejob:putInVehicle', target)
    end
end)

RegisterNetEvent('ars_policejob:putOutVehicle', function(target)
    if not hasJob(source, Config.Interactions.jobs) then return end

    local target = tonumber(target)
    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target)
    if target < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        print(source .. ' probible modder')
    else
        TriggerClientEvent('ars_policejob:putOutVehicle', target)
    end
end)
