RegisterNetEvent('ars_policejob:handcuff', function(data)
	if not hasJob(source, Config.Interactions.jobs) or not source or source < 1 then return end

	local sourcePed = GetPlayerPed(source)
	local targetPed = GetPlayerPed(data.targetServerId)

	if data.targetServerId == -1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
		print(source .. ' probile modder')
	else
		TriggerClientEvent('ars_policejob:handcuff', tonumber(data.targetServerId), data.handcuffStatus)
		exports.ox_inventory:RemoveItem(source, Config.ItemCuffs, 1)
	end
end)

RegisterNetEvent('ars_policejob:uncuff', function(data)
	if not hasJob(source, Config.Interactions.jobs) then return end

	local sourcePed = GetPlayerPed(source)
	local targetPed = GetPlayerPed(data.targetServerId)

	if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
		print(source .. ' probile modder')
	else
		TriggerClientEvent('ars_policejob:uncuff', tonumber(data.targetServerId))
	end
end)
