player = {}
player.adam = nil
player.status = nil
player.location = nil

local receiveNotifications = true


local function sendNotification(adam)
    if not receiveNotifications then return end
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

local function getCurrentLocation()
    local playerPed = cache.coords and cache.coords or cache.ped
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local currentArea = GetLabelText(tostring(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)))
    local currentLocation = currentArea
    if not zone then zone = "UNKNOWN" end

    if currentStreetName and currentStreetName ~= "" then
        currentLocation = currentLocation .. ", " .. currentArea
    end

    return currentLocation
end

local function createEmergencyBlip()
    local blipId = AddBlipForCoord(cache.coords)
    SetBlipSprite(blipId, 161)
    SetBlipScale(blipId, 1.2)
    SetBlipColour(blipId, color)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Richiedi supporto')
    EndTextCommandSetBlipName(blipId)
    Wait(6 * 1000)
    RemoveBlip(blipId)
end



lib.registerMenu({
    id = 'police_status_menu',
    title = '🚨 Set Your Adam Status 🚨',
    position = 'top-right',
    options = {
        { label = 'Patrolling',                     description = 'Status Code: 10-8',  args = { status = "10-8", }, icon = "fas fa-user-clock" },
        { label = 'On Scene',                       description = 'Status Code: 10-97', args = { status = "10-97" }, icon = "fas fa-map-marked-alt" },
        { label = 'Busy',                           description = 'Status Code: 10-6',  args = { status = "10-6" },  icon = "fas fa-user-clock" },
        { label = 'Responding',                     description = 'Status Code: 10-8',  args = { status = "10-8" },  icon = "fas fa-user-clock" },
        { label = 'Pursuit in Progress',            description = 'Status Code: 10-80', args = { status = "10-80" }, icon = "fas fa-car-crash" },
        { label = 'Needs Backup',                   description = 'Status Code: 11-99', args = { status = "11-99" }, icon = "fas fa-exclamation-triangle" },
        { label = 'Taking a Break',                 description = 'Status Code: 10-7',  args = { status = "10-7" },  icon = "fas fa-coffee" },
        { label = 'Accident, Serious Injury',       description = 'Code 11-80',         args = { status = "11-80" }, icon = "fas fa-car-crash" },
        { label = 'Accident, Minor Injury',         description = 'Code 11-81',         args = { status = "11-81" }, icon = "fas fa-car-crash" },
        { label = 'Accident, Property Damage Only', description = 'Code 11-82',         args = { status = "11-82" }, icon = "fas fa-car-crash" },
        { label = 'Needs Medical Assistance',       description = 'Code 11-47',         args = { status = "11-47" }, icon = "fas fa-hospital" },
        { label = 'Investigating',                  description = 'Status Code: 10-29', args = { status = "10-29" }, icon = "fas fa-search" },
        { label = 'In Custody',                     description = 'Status Code: 10-15', args = { status = "10-15" }, icon = "fas fa-male" },
        { label = 'Officer Down',                   description = 'Code 11-45',         args = { status = "11-45" }, icon = "fas fa-skull-crossbones" },
        { label = 'Emergency Response',             description = 'Status Code: 10-3',  args = { status = "10-3" },  icon = "fas fa-exclamation" },
    }
}, function(selected, scrollIndex, args)
    player.status = args.status
    player.location = getCurrentLocation()

    TriggerServerEvent("ars_policejob:sendStatusNotification", { adam = player.adam or "N/A", status = player.status, location = player.location })

    if player.status == "11-99" then
        createEmergencyBlip()
    end

    utils.showNotification(locale("adam_status_changed"))
end)

local function openPoliceMenu()
    if hasJob(Config.AccessToMenu) then
        lib.registerMenu({
            id = 'police_main_menu',
            title = '👮‍♂️ Police Menu 👮‍♂️',
            position = 'top-right',

            options = {
                { label = 'Set Your Adam',                description = player.adam and ('Current adam %s'):format(player.adam) or 'Set your adam!',                 icon = "fas fa-user" },
                { label = 'Set Your Adam Status',         description = player.status and ('Current Status %s'):format(player.status) or 'Set your current status!', icon = "fas fa-comment" },
                { label = 'Receive status notifications', description = 'enable if to receive other police officer status notifications',                            icon = "fas fa-info",   checked = receiveNotifications },

            },
            onCheck = function(selected, checked, args)
                if selected == 3 then
                    receiveNotifications = checked
                end
            end,
        }, function(selected, scrollIndex, args)
            if selected == 1 then
                local input = lib.inputDialog('🚓 LSPD', {
                    { type = 'number', label = 'Enter Your Adam Number', description = 'Enter the number of your assigned adam', icon = 'hashtag' },
                })

                if not input then return end
                if not input[1] then return end

                player.adam = input[1]
                utils.showNotification(("You are now in adam %s"):format(player.adam))
                openPoliceMenu()
            elseif selected == 2 then
                lib.showMenu('police_status_menu')
            end
        end)

        lib.showMenu('police_main_menu')
    end
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
