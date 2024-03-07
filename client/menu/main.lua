local GetEntityCoords = GetEntityCoords
local Wait = Wait
local RemoveBlip = RemoveBlip
local GetResourceState = GetResourceState
local PlaySoundFrontend = PlaySoundFrontend
local RegisterNetEvent = RegisterNetEvent
local GetGameTimer = GetGameTimer
local IsControlJustReleased = IsControlJustReleased

player.adam = nil
player.status = nil
player.location = nil
player.receiveNotifications = true
player.frequencyToJoin = 0

local function createEmergencyBlip(data)
    if not hasJob(Config.Interactions.jobs) then return end

    local blip = utils.createBlip(data)

    Wait(6 * 1000)
    RemoveBlip(blip)
end

RegisterNetEvent('ars_policejob:createEmergencyBlip', createEmergencyBlip)


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

    local message = ("\n🚓 %s %s  \n🔢 %s %s  \n🗺️ %s %s"):format(locale("adam_notif_label"), adam.adam, locale("status_notif_label"), adam.status, locale("localtion_notif_label"), adam.location)

    lib.notify({
        title = locale("status_notif_title"),
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
    if hasJob(Config.AccessToMenu) then
        if player.inDuty() == false then return utils.showNotification(locale("your_off_duty")) end
        lib.showMenu("police_main_menu")
    end
end

RegisterNetEvent("ars_policejob:broadcastMsg", function(data)
    local reason = data.reason
    lib.notify({
        title = locale("broadcast_notif_title"),
        description = reason,
        position = 'bottom-right',
        duration = 8000,
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
end)

function openAdamMenu()
    lib.setMenuOptions('adam_menu', { label = locale("set_adam_label"), description = player.adam and ('Current adam %s'):format(player.adam) or locale("set_adam_label"), icon = "fas fa-user" }, 1)
    lib.setMenuOptions('adam_menu', { label = locale("set_adam_label_status"), description = player.status and ('Current Status %s'):format(player.status) or locale("set_adam_label_status"), icon = "fas fa-comment" }, 2)
    lib.setMenuOptions('adam_menu', { label = locale("adam_receive_notif_label"), description = locale("adam_receive_notif_dec"), icon = "fas fa-info", checked = player.receiveNotifications }, 3)

    lib.showMenu('adam_menu')
end

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
        lib.setMenuOptions('police_meeting_menu', { label = string.len(data.reason) < 50 and ("%s %s"):format(locale("meeting_reason_label"), data.reason) or locale("read_meeting_reason_label"), description = data.reason, icon = 'info' }, 1)
        lib.setMenuOptions('police_meeting_menu', { label = ("%s %s"):format(locale("fz_meeting"), data.radio), description = ("%s %s"):format(locale("join_fz"), data.radio), icon = 'radio' }, 2)
        player.frequencyToJoin = data.radio

        lib.notify({
            title = locale("status_notif_title"),
            description = locale("open_called_meeting_menu"),
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

lib.addKeybind({
    name = 'open_police_menu',
    description = 'Open police menu',
    defaultKey = Config.OpenMenuKey,
    onReleased = function(self)
        openPoliceMenu()
    end
})
