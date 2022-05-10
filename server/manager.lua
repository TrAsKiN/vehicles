RegisterNetEvent('entityCreated', function (entity)
    if GetEntityType(entity) == 2 and not Entity(entity).state.vehiclesInit then
        Entity(entity).state:set('vehiclesInit', true, true)
    end
end)
