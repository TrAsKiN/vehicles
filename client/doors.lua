local DOORS_INPUT = GetConvar('doorsInput', 'U')

RegisterKeyMapping('vehicle:doors:toggle', exports[RESOURCE_NAME]:getLocale().input.doors, 'KEYBOARD', DOORS_INPUT)
RegisterCommand('vehicle:doors:toggle', function()
    local playerPed = PlayerPedId()
    local vehicle = nil
    if IsPedInAnyVehicle(playerPed) then
        vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    else
        vehicle = getVehicleAhead()
    end
    if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        if GetVehicleDoorLockStatus(vehicle) > 1 then
            TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 1)
        else
            SetVehicleDoorsShut(vehicle, false)
            TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 2)
        end
    end
end, true)

AddEventHandler('vehicle:data:synced', function (vehicles)
    for vehicleId, vehicleData in pairs(vehicles) do
        local vehicle = NetToVeh(vehicleId)
        if IsEntityAVehicle(vehicle) then
            if type(vehicleData.doors) ~= 'nil' then
                SetVehicleDoorsLocked(vehicle, vehicleData.doors)
            end
        end
    end
end)
