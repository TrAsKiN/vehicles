local vehicles = {}

RegisterNetEvent('vehicle:data:init')
AddEventHandler('vehicle:data:init', function()
    TriggerClientEvent('vehicle:data:sync', source, vehicles)
end)

RegisterNetEvent('vehicle:data:toSync')
AddEventHandler('vehicle:data:toSync', function(vehicleId, name, data)
    if not vehicles[vehicleId] then
        vehicles[vehicleId] = {}
    end
    vehicles[vehicleId][name] = data
    TriggerClientEvent('vehicle:data:sync', -1, vehicles)
end)

AddEventHandler('entityRemoved', function(entityId)
    vehicles[entityId] = nil
end)
