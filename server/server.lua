QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('qb-vehicleshop.requestInfo')
AddEventHandler('qb-vehicleshop.requestInfo', function()
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local rows    

    TriggerClientEvent('qb-vehicleshop.receiveInfo', src, xPlayer.PlayerData.money['bank'], xPlayer.PlayerData.firstname)
    TriggerClientEvent("qb-vehicleshop.notify", src, 'error', 'Use A and D To Rotate')
end)

QBCore.Functions.CreateCallback('qb-vehicleshop.isPlateTaken', function (source, cb, plate)
    QBCore.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        cb(result[1] ~= nil)
    end)
end)

RegisterServerEvent('qb-vehicleshop.CheckMoneyForVeh')
AddEventHandler('qb-vehicleshop.CheckMoneyForVeh', function(veh, price, name, vehicleProps)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)

    if xPlayer.PlayerData.money['bank'] >= tonumber(price) then
        xPlayer.Functions.RemoveMoney('bank', tonumber(price))
        local vehiclePropsjson = json.encode(vehicleProps)
        if Config.SpawnVehicle then
            stateVehicle = 0
        else
            stateVehicle = 1
        end

        exports.oxmysql:execute("INSERT INTO `player_vehicles` (`license`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES(@license, @citizenid, @vehicle, @hash, @mods, @plate, @state)", {
            ['@license'] = xPlayer.PlayerData.license,
            ['@citizenid'] = xPlayer.PlayerData.citizenid,
            ['@vehicle'] = veh,
            ['@hash'] = GetHashKey(veh),
            ['@mods'] = json.encode(vehicleProps),
            ['@plate'] = vehicleProps.plate,
            ['@state'] = stateVehicle,
        })
        TriggerClientEvent("qb-vehicleshop.successfulbuy", source, name, vehicleProps.plate, price)
        TriggerClientEvent('qb-vehicleshop.receiveInfo', source, xPlayer.PlayerData.money['bank'])    
        TriggerClientEvent('qb-vehicleshop.spawnVehicle', source, veh, vehicleProps.plate)
    else
        TriggerClientEvent("qb-vehicleshop.notify", source, 'error', 'Not Enough Money')
    end
end)
