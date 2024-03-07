local TriggerServerEvent = TriggerServerEvent

-- # Main menu
lib.registerMenu({
    id = 'police_main_menu',
    title = locale("police_menu_title"),
    position = 'top-right',
    options = {
        { label = locale("open_adam_menu_label"),  description = locale("open_adam_menu_description"), icon = "fas fa-car" },
        { label = locale("broadcast_alert_label"), description = locale("broadcast_alert_label_dsc"),  icon = "fas fa-bullhorn" },
        { label = 'Interdict area',                icon = 'fa-tower-broadcast' },
        { label = locale("call_metting_label"),    icon = 'radio' },
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        openAdamMenu()
    elseif selected == 2 then
        local input = lib.inputDialog(locale("broadcast_input_title"), {
            { type = 'input', label = locale("broadcast_input_reason"), description = locale("broadcast_input_reason_desc"), required = true, min = 5, max = 500 },
        })
        if not input then return end

        local reason = input[1]

        TriggerServerEvent("ars_policejob:broadcastMsg", { reason = reason })
    elseif selected == 3 then
        openDialogMenu()
    elseif selected == 4 then
        local jobGrade = getPlayerJobGrade()

        if jobGrade >= Config.MettingMenuGrade then
            local input = lib.inputDialog(locale("open_meeting_menu_label"), {
                { type = 'input',    label = locale("meeting_input_reason"),      description = locale("meeting_input_reason_desc"), required = true, max = 500 },
                { type = 'number',   label = locale("meeting_input_radio"),       description = locale("meeting_input_radio_desc"),  required = true, icon = 'hashtag', max = 999 },
                { type = 'checkbox', label = locale("meeting_input_confirmation") },
            })
            if not input then return end
            if not input[3] then return end

            local reason = input[1]
            local radio = input[2]

            TriggerServerEvent("ars_policejob:callMeeting", { reason = reason, radio = radio })
        end
    end
end)
lib.registerMenu({
    id = 'police_meeting_menu',
    title = locale("police_meeting_menu_title"),
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
    title = locale("adam_menu_title"),
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
        local input = lib.inputDialog(locale("input_set_adam_title"), {
            { type = 'number', label = locale("input_enter_adam_num"), description = locale("input_enter_adam_num_desc"), icon = 'hashtag', max = 999 },
        })

        if not input then return end
        if not input[1] then return end

        player.adam = input[1]
        utils.showNotification(("%s %s"):format(locale("your_in_adam_x"), player.adam))
        openPoliceMenu()
    elseif selected == 2 then
        lib.showMenu('adam_status_menu')
    end
end)

-- #Adam status menu
lib.registerMenu({
    id = 'adam_status_menu',
    title = locale("adam_status_menu_title"),
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
        local data = {
            name = locale("emergency_blip_label"),
            type = 161,
            scale = 1.2,
            color = 1,
            pos = cache.coords or GetEntityCoords(cache.ped)
        }
        TriggerServerEvent('ars_policejob:createEmergencyBlip', data)
    end

    utils.showNotification(locale("adam_status_changed"))
end)
