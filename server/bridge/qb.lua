local QBCore = GetResourceState('qb-core'):find('start') and exports['qb-core']:GetCoreObject() or nil

if not QBCore then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = QBCore.Functions.GetPlayer(target)
    xPlayer.Functions.RemoveMoney(account, amount)
end

function isPoliceOfficer(target)
    local xPlayer = QBCore.Functions.GetPlayer(target)

    return xPlayer.PlayerData.job.name == Config.PoliceJobName
end
