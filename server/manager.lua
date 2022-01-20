local vehicles = {}

RegisterNetEvent('vehicle:data:init')
AddEventHandler('vehicle:data:init', function()
    local playerId = source
    print("Retrieve vehicle data...", "Player: ".. playerId)
    TriggerClientEvent('vehicle:data:sync', playerId, vehicles)
end)

RegisterNetEvent('vehicle:data:toSync')
AddEventHandler('vehicle:data:toSync', function(vehicleId, name, data)
    print("Receiving data to synchronize...", "From: ".. source)
    if not vehicles[vehicleId] then
        vehicles[vehicleId] = {}
    end
    vehicles[vehicleId][name] = data
    TriggerClientEvent('vehicle:data:sync', -1, vehicles)
end)

AddEventHandler('playerEnteredScope', function (data)
    print("Two players meeting, forcing synchronization...", data['player'] .." meet ".. data['for'])
    TriggerClientEvent('vehicle:data:sync', data['for'], vehicles)
    TriggerClientEvent('vehicle:data:sync', data['player'], vehicles)
end)

AddEventHandler('entityRemoved', function(entityId)
    if vehicles[entityId] then
        print("A synchronized entity no longer exists, removing...", "Entity: ".. entityId)
        vehicles[entityId] = nil
        TriggerClientEvent('vehicle:data:sync', -1, vehicles)
    end
end)
