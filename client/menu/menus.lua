local TriggerServerEvent = TriggerServerEvent

-- # Main menu
lib.registerMenu({
    id = 'police_main_menu',
    title = '👮‍♂️ Police Menu 👮‍♂️',
    position = 'top-right',
    options = {
        { label = 'Adam', description = 'Adam settings', icon = "fas fa-car" },

    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        openAdamMenu()
    elseif selected == 2 then
        local input = lib.inputDialog('Call Meeting', {
            { type = 'input',    label = 'Reason',   description = 'Reason for the meeting',             required = true, max = 500 },
            { type = 'number',   label = 'Radio Fz', description = 'Radio frequency that all will join', required = true, icon = 'hashtag', max = 999 },
            { type = 'checkbox', label = 'Confirm' },
        })
        if not input then return end
        if not input[3] then return end

        local reason = input[1]
        local radio = input[2]

        TriggerServerEvent("ars_policejob:callMeeting", { reason = reason, radio = radio })
    elseif selected == 3 then
        openDialogMenu()
    end
end)
lib.registerMenu({
    id = 'police_meeting_menu',
    title = '👮‍♂️ Meeting Info 👮‍♂️',
    position = 'top-right',
    options = {}
}, function(selected, scrollIndex, args)
    if selected == 1 then
        lib.showMenu("police_meeting_menu")
    elseif selected == 2 then
        joinRadio(player.frequencyToJoin)
    end
end)




-- # Adam menu
lib.registerMenu({
    id = 'adam_menu',
    title = '👮‍♂️ Adam Menu 👮‍♂️',
    position = 'top-right',

    options = {},
    onCheck = function(selected, checked, args)
        if selected == 3 then
            player.receiveNotifications = checked
        end
    end,
    onClose = function(keyPressed)
        lib.showMenu("police_main_menu")
    end,
}, function(selected, scrollIndex, args)
    if selected == 1 then
        local input = lib.inputDialog('🚓 LSPD', {
            { type = 'number', label = 'Enter Your Adam Number', description = 'Enter the number of your assigned adam', icon = 'hashtag', max = 999 },
        })

        if not input then return end
        if not input[1] then return end

        player.adam = input[1]
        utils.showNotification(("You are now in adam %s"):format(player.adam))
        openPoliceMenu()
    elseif selected == 2 then
        lib.showMenu('adam_status_menu')
    end
end)

-- #Adam status menu
lib.registerMenu({
    id = 'adam_status_menu',
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
    },
    onClose = function(keyPressed)
        lib.showMenu("adam_menu")
    end,
}, function(selected, scrollIndex, args)
    if not player.adam then return utils.showNotification(locale("no_adam_set")) end
    player.status = args.status
    player.location = utils.getCurrentLocation()

    TriggerServerEvent("ars_policejob:sendStatusNotification", { adam = player.adam or "N/A", status = player.status, location = player.location })

    if player.status == "11-99" then
        createEmergencyBlip()
    end

    utils.showNotification(locale("adam_status_changed"))
end)
