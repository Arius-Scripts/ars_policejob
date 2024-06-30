RegisterNetEvent('ars_policejob:drag', function(target)
    if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

    local sourcePed = GetPlayerPed(source)
    local targetPed = GetPlayerPed(target)

    if target == -1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
        print(source .. ' probile modder')
    else
        TriggerClientEvent('ars_policejob:drag', tonumber(target), source)
    end
end)
