player.onDuty = false

function player.inDuty()
    if Config.UseInternalDuty then return player.onDuty end

    return true
end

if not Config.UseInternalDuty then return end

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
                        player.onDuty = true
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
                        player.onDuty = false
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
