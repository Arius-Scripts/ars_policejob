for index, station in pairs(Config.PoliceStations) do
    exports.ox_target:addBoxZone({
        coords = station.bossmenu.pos,
        size = vector3(2.0, 2.0, 2.0),
        drawSprite = true,
        groups = station.jobs,
        options = {
            {
                name = "open_boosmenu" .. index,
                icon = 'fa-solid fa-road',
                label = locale("bossmenu_label"),
                groups = station.jobs,
                onSelect = function(data)
                    if getPlayerJobGrade() >= station.bossmenu.min_grade then
                        openBossMenu(station.jobs[1])
                    else
                        print("no access")
                    end
                end
            }
        }
    })
end
