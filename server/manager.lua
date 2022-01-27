local vehicles = {}

RegisterNetEvent('vehicle:data:init')
AddEventHandler('vehicle:data:init', function()
    local playerId = source
    log.debug("Retrieving vehicles data...", "Player: ".. playerId)
    TriggerClientEvent('vehicle:data:sync', playerId, vehicles)
end)

RegisterNetEvent('vehicle:data:toSync')
AddEventHandler('vehicle:data:toSync', function(vehicleId, name, data)
    log.debug("Receiving data to synchronize...", "From Player: ".. source)
    if not vehicles[vehicleId] then
        vehicles[vehicleId] = {}
    end
    vehicles[vehicleId][name] = data
    TriggerClientEvent('vehicle:data:sync', -1, vehicles)
end)

AddEventHandler('playerEnteredScope', function (data)
    log.debug("Player meets another, force synchronization...", "Player: ".. data['player'])
    TriggerClientEvent('vehicle:data:sync', data['player'], vehicles)
end)

AddEventHandler('entityRemoved', function(entityId)
    if vehicles[entityId] then
        log.debug("A synchronized entity no longer exists, removing...", "Entity: ".. entityId)
        vehicles[entityId] = nil
        TriggerClientEvent('vehicle:data:sync', -1, vehicles)
    end
end)
