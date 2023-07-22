local ESX = GetResourceState('es_extended'):find('start') and exports['es_extended']:getSharedObject() or nil

if not ESX then return end

function removeAccountMoney(target, account, amount)
    local xPlayer = ESX.GetPlayerFromId(target)
    xPlayer.removeAccountMoney(account, amount)
end

function hasJob(target, jobs)
    local xPlayer = ESX.GetPlayerFromId(target)

    if type(jobs) == "table" then
        for index, jobName in pairs(jobs) do
            if xPlayer.job.name == jobName then return true end
        end
    else
        return xPlayer.job.name == jobs
    end

    return false
end
