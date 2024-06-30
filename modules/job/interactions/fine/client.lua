if not Config.Interactions.enable or not Config.Interactions.fines then return end

local GetPlayerServerId            = GetPlayerServerId
local NetworkGetPlayerIndexFromPed = NetworkGetPlayerIndexFromPed
local TriggerServerEvent           = TriggerServerEvent

function player.finePlayer(target)
    local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(target))

    local input = lib.inputDialog(locale('fine_dialog_title'), {
        {
            type = 'number',
            label = locale('fine_amount_title'),
            icon = 'hashtag',
            required = true
        },
        {
            type = 'input',
            label = locale('fine_reason_title'),
            icon = 'pencil',
            min = 4,
            required = true,
        }
    })

    if not input then return end

    local amount = input[1]
    local reason = input[2]

    TriggerServerEvent('ars_policejob:finePlayer', targetServerId, amount, reason)
end
