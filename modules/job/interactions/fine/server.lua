RegisterNetEvent('ars_policejob:finePlayer', function(target, amount, reason)
    if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

    removeAccountMoney(target, 'bank', amount)
    TriggerClientEvent('ars_policejob:showNotification', target, locale('have_been_fined'):format(amount, reason))
end)
