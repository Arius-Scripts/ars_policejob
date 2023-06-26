local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    xPlayer.removeAccountMoney(account, amount)
end

function isPoliceOfficer(target)
    local xPlayer = ESX.GetPlayerFromId(target)

    return xPlayer.job.name == Config.PoliceJobName
end
