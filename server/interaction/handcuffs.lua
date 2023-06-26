RegisterNetEvent('ars_policejob:handcuff', function(data)
	if not isPoliceOfficer(source) or not source or source < 1 then return end

	local sourcePed = GetPlayerPed(source)
	local targetPed = GetPlayerPed(data.targetServerId)

	if data.targetServerId == -1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
		print(source .. ' probile modder')
	else
		TriggerClientEvent('ars_policejob:handcuff', tonumber(data.targetServerId), data.handcuffStatus)
		exports.ox_inventory:RemoveItem(source, 'cuffs', 1)
	end
end)

RegisterNetEvent('ars_policejob:uncuff', function(data)
	if not isPoliceOfficer(source) then return end

	local sourcePed = GetPlayerPed(source)
	local targetPed = GetPlayerPed(data.targetServerId)

	if data.targetServerId < 1 or #(GetEntityCoords(sourcePed) - GetEntityCoords(targetPed)) > 4.0 then
		print(source .. ' probile modder')
	else
		TriggerClientEvent('ars_policejob:uncuff', tonumber(data.targetServerId))
	end
end)
