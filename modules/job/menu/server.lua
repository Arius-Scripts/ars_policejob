function sendNotification(data)
    if not hasJob(source, Config.AccessToMenu) or not source or source < 1 then return end

    local job = playerJob(source)
    for k, playerId in ipairs(GetPlayers()) do
        if hasJob(playerId, job) then
            TriggerClientEvent(data.eventName, playerId, data)
        end
    end
end

RegisterNetEvent("ars_policejob:sendStatusNotification", function(data)
    if not hasJob(source, Config.AccessToMenu) or not source or source < 1 then return end

    sendNotification({
        eventName = "ars_policejob:sendStatusNotification",
        adam = data.adam,
        status = data.status,
        location = data.location
    })
end)

RegisterNetEvent("ars_policejob:callMeeting", function(data)
    if not hasJob(source, Config.AccessToMenu) or not source or source < 1 then return end

    sendNotification({
        eventName = "ars_policejob:callMeeting",
        reason = data.reason,
        radio = data.radio,
    })
end)

RegisterNetEvent("ars_policejob:broadcastMsg", function(data)
    if not hasJob(source, Config.AccessToMenu) or not source or source < 1 then return end

    for k, playerId in ipairs(GetPlayers()) do
        TriggerClientEvent("ars_policejob:broadcastMsg", playerId, data)
    end
end)
