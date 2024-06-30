if not Config.CanBreakCuffs then return end

exports('breakCuffs', function(data, slot)
    exports.ox_inventory:useItem(data, function(data)
        if data then
            if player.cuffed then
                local success = lib.skillCheck({ 'easy', 'easy', "medium", 'easy', "medium", "hard" },
                    { 'w', 'a', 's', 'd' })

                if not success then return end

                TriggerEvent("ars_policejob:uncuff")
            end
        end
    end)
end)
