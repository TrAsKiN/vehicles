RegisterNetEvent('entityCreated', function (entity)
    if GetEntityType(entity) == 2 and HasVehicleBeenOwnedByPlayer(entity) then
        Entity(entity).state:set('vehiclesInit', true, true)
    end
end)

AddStateBagChangeHandler(nil, nil, function (bagName, key, value, reserved, replicated)
    -- log.debug(string.format("%s: %s = %s (replicated: %s)", bagName, key, type(value) == 'table' and json.encode(value, {indent = true}) or tostring(value), tostring(replicated)))
end)
