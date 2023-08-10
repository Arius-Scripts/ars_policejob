player.adam = nil
player.status = nil
player.location = nil
player.receiveNotifications = true
player.frequencyToJoin = 0

function createEmergencyBlip()
    local data = {
        name = 'Help',
        type = 161,
        scale = 1.2,
        color = 1,
        pos = cache.coords or GetEntityCoords(playerPed)
    }
    local blip = utils.createBlip(data)

    Wait(6 * 1000)
    RemoveBlip(blip)
end

function joinRadio(fz)
    if GetResourceState('saltychat'):find('start') then
        exports.saltychat:SetRadioChannel(fz, true)
    else
        exports['pma-voice']:setVoiceProperty('radioEnabled', true)
        exports['pma-voice']:setVoiceProperty('micClicks', true)
        exports['pma-voice']:setRadioChannel(tonumber(fz))
    end
end

local function sendNotification(adam)
    if not player.receiveNotifications or not player.inDuty() then return end
    PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)

    local message = ("\n🚓 Adam %s  \n🔢 Status: %s  \n🗺️ Location: %s"):format(adam.adam, adam.status, adam.location)

    lib.notify({
        title = '📢 LSPD NOTIFICATION 📢',
        description = message,
        position = 'bottom-right',
        duration = 3000,
        style = {
            backgroundColor = '#1C1C1C',
            color = '#C1C2C5',
            borderRadius = '8px',
            ['.description'] = {
                fontSize = '16px',
                color = '#B0B3B8'
            },
        },
        icon = 'fas fa-badge-shield-altad',
        iconColor = '#FEBD69'
    })
end

function openPoliceMenu()
    -- print(player.inDuty())

    if player.inDuty() == false then return utils.showNotification(locale("your_off_duty")) end

    if hasJob(Config.AccessToMenu) then
        local jobGrade = getPlayerJobGrade()

        lib.setMenuOptions('police_main_menu', jobGrade >= 2 and { label = 'Call meeting', icon = 'radio' } or {}, 2)
        lib.showMenu("police_main_menu")
    end
end

function openAdamMenu()
    lib.setMenuOptions('adam_menu', { label = 'Set Your Adam', description = player.adam and ('Current adam %s'):format(player.adam) or 'Set your adam!', icon = "fas fa-user" }, 1)
    lib.setMenuOptions('adam_menu', { label = 'Set Your Adam Status', description = player.status and ('Current Status %s'):format(player.status) or 'Set your current status!', icon = "fas fa-comment" }, 2)
    lib.setMenuOptions('adam_menu', { label = 'Receive status notifications', description = 'enable if to receive other police officer status notifications', icon = "fas fa-info", checked = player.receiveNotifications }, 3)

    lib.showMenu('adam_menu')
end

RegisterCommand('testmenu', function()
    openPoliceMenu()
end)

RegisterNetEvent("ars_policejob:sendStatusNotification", function(data)
    if hasJob(Config.AccessToMenu) then
        sendNotification({
            adam = data.adam,
            status = data.status,
            location = data.location
        })
    end
end)

RegisterNetEvent("ars_policejob:callMeeting", function(data)
    if hasJob(Config.AccessToMenu) then
        lib.setMenuOptions('police_meeting_menu', { label = string.len(data.reason) < 50 and ("Meeting Reason: %s"):format(data.reason) or "Read the reason under", description = data.reason, icon = 'info' }, 1)
        lib.setMenuOptions('police_meeting_menu', { label = ("Meeting in Fz: %s"):format(data.radio), description = ("Join frequncy %s"):format(data.radio), icon = 'radio' }, 2)
        player.frequencyToJoin = data.radio

        lib.notify({
            title = '📢 LSPD NOTIFICATION 📢',
            description = "A high grade called a meeting Press [U] for more info",
            position = 'top-center',
            duration = 5000,
        })

        local startTime = GetGameTimer()
        local timeout = 1 * 60000
        while true do
            if IsControlJustReleased(0, 303) then
                lib.showMenu("police_meeting_menu")
                break
            end

            if GetGameTimer() - startTime >= timeout then
                break
            end
            Wait(1)
        end
    end
end)
