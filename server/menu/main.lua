RegisterNetEvent("ars_policejob:sendStatusNotification", function(data)
    if not hasJob(source, Config.AccessToMenu) or not source or source < 1 then return end

    local job = playerJob(source)
    for k, playerId in ipairs(GetPlayers()) do
        if hasJob(playerId, job) then
            TriggerClientEvent("ars_policejob:sendStatusNotification", playerId, { adam = data.adam, status = data.status, location = data.location })
        end
    end
end)
