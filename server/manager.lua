RegisterNetEvent('entityCreated', function (entity)
    if GetEntityType(entity) == 2 then
        Entity(entity).state:set('vehiclesInit', true, true)
    end
end)
