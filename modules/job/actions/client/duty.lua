function player.inDuty()
    if not Config.UseInternalDuty then return true end

    if player.onDuty == nil then player.onDuty = lib.callback.await('ars_policejob:getDutyStatus', false) end

    return player.onDuty
end

if not Config.UseInternalDuty then return end

RegisterNetEvent("ars_policejob:dutyStatusUpdated", function(value)
    player.onDuty = value
end)


for index, station in pairs(Config.PoliceStations) do
    exports.ox_target:addBoxZone({
        coords = station.duty,
        size = vector3(1.0, 1.0, 1.0),
        drawSprite = true,
        groups = station.jobs,
        options = {
            {
                name = "clock_in" .. index,
                icon = 'fa-solid fa-road',
                label = locale("clock_in"),
                groups = station.jobs,
                onSelect = function(data)
                    if not player.onDuty then
                        TriggerServerEvent("ars_policejob:updateDuty", true)
                        utils.showNotification(locale("clocked_in"))
                    else
                        utils.showNotification(locale("already_in_duty"))
                    end
                end
            },
            {
                name = "clock_out" .. index,
                icon = 'fa-solid fa-road',
                label = locale("clock_out"),
                groups = station.jobs,
                onSelect = function(data)
                    if player.onDuty then
                        TriggerServerEvent("ars_policejob:updateDuty", false)
                        utils.showNotification(locale("clocked_out"))
                    else
                        utils.showNotification(locale("already_off_duty"))
                    end
                end
            },
        }
    })
end

exports("onDuty", function()
    return player.inDuty()
end)
