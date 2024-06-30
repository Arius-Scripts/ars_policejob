local TriggerServerEvent = TriggerServerEvent
local RegisterNetEvent = RegisterNetEvent
local AddBlipForRadius = AddBlipForRadius
local SetBlipColour = SetBlipColour
local SetBlipAlpha = SetBlipAlpha
local Wait = Wait
local RemoveBlip = RemoveBlip

function openDialogMenu()
    local input = lib.inputDialog(locale('restrict_area_dialog_title'), {
        {
            type = 'input',
            label = locale('restrict_area_message_title'),
            description = locale('restrict_area_message_description'),
            required = true,
        },
        {
            type = 'select',
            label = locale('restrict_area_radius_title'),
            description = locale('restrict_area_radius_description'),
            icon = 'hashtag',
            required = true,
            options = {
                { value = '100.00', label = '100' },
                { value = '200.00', label = '200' },
                { value = '200.00', label = '300' },
                { value = '400.00', label = '400' },
            }
        },
        {
            type = 'select',
            label = locale('restrict_area_type_title'),
            description = locale('restrict_area_type_description'),
            icon = 'hashtag',
            required = true,
            options = {
                { value = 1, label = locale('restrict_area_type_1') },
                { value = 2, label = locale('restrict_area_type_2') },
                { value = 3, label = locale('restrict_area_type_3') },
            }
        },
        {
            type = 'number',
            label = locale('restrict_area_time_title'),
            description = locale('restrict_area_time_description'),
            required = true
        },
        { type = 'checkbox', label = 'Confirm', required = true },
    })

    if not input then return end

    local reason = input[1]
    local radius = input[2]
    local type = input[3]
    local time = input[4]
    local confirm = input[5]

    if not confirm then return end

    TriggerServerEvent('ars_policejob:activateBlip', {
        reason = reason,
        radius = radius,
        type = type,
        position = cache.coords,
        time = time * 60000
    })
end

RegisterNetEvent('ars_policejob:activateBlip', function(data)
    local blip = AddBlipForRadius(data.position, tonumber(data.radius))

    SetBlipColour(blip, data.type)
    SetBlipAlpha(blip, 128)
    utils.showNotification(data.reason)

    Wait(data.time)
    RemoveBlip(blip)
end)
