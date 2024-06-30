local DrawMarker = DrawMarker
local IsControlJustReleased = IsControlJustReleased

local stashes = {}

for index, station in pairs(Config.PoliceStations) do
    for id, stash in pairs(station.stash) do
        stashes[stash] = lib.points.new({
            coords = stash.pos,
            distance = 1,
            onEnter = function(self)
                if hasJob(station.jobs) then
                    lib.showTextUI(locale('open_stash_label'))
                end
            end,
            onExit = function(self)
                lib.hideTextUI()
            end,
            nearby = function(self)
                if hasJob(station.jobs) then
                    DrawMarker(2, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.2,
                        0.2, 0.2, 199, 208, 209, 100, true, true, 2, nil, nil, false)

                    if IsControlJustReleased(0, 38) then
                        exports.ox_inventory:openInventory('stash', id)
                    end
                end
            end

        })
    end
end
