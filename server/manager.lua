local vehicles = {}

RegisterNetEvent('vehicle:data:init')
AddEventHandler('vehicle:data:init', function()
    local playerId = source
    print("Retrieving vehicles data...", "Player: ".. playerId)
    TriggerClientEvent('vehicle:data:sync', playerId, vehicles)
end)

RegisterNetEvent('vehicle:data:toSync')
AddEventHandler('vehicle:data:toSync', function(vehicleId, name, data)
    print("Receiving data to synchronize...", "From Player: ".. source)
    if not vehicles[vehicleId] then
        vehicles[vehicleId] = {}
    end
    vehicles[vehicleId][name] = data
    TriggerClientEvent('vehicle:data:sync', -1, vehicles)
end)

AddEventHandler('playerEnteredScope', function (data)
    print("Player meets another, force synchronization...", "Player: ".. data['player'])
    TriggerClientEvent('vehicle:data:sync', data['player'], vehicles)
end)

AddEventHandler('entityRemoved', function(entityId)
    if vehicles[entityId] then
        print("A synchronized entity no longer exists, removing...", "Entity: ".. entityId)
        vehicles[entityId] = nil
        TriggerClientEvent('vehicle:data:sync', -1, vehicles)
    end
end)
