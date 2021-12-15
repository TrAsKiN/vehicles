local RESOURCE_NAME = GetCurrentResourceName()
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
    if vehicle then
        if GetVehicleDoorLockStatus(vehicle) > 1 then
            SetVehicleDoorsLocked(vehicle, 1)
        else
            SetVehicleDoorsLocked(vehicle, 2)
        end
    end
end, true)

function getVehicleAhead()
    local LAND_VEHICLES = 131075
    local FLYING_VEHICLES = 28675
    local RADIUS = 2.75
    local MODEL = 0
    local playerPed = PlayerPedId()
    local position = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * 1.66
    if IsAnyVehicleNearPoint(position, RADIUS) then
        local landVehicle = GetClosestVehicle(position, RADIUS, MODEL, LAND_VEHICLES)
        if IsEntityAVehicle(landVehicle) then
            return landVehicle
        end
        local flyingVehicle = GetClosestVehicle(position, RADIUS, MODEL, FLYING_VEHICLES)
        if IsEntityAVehicle(flyingVehicle) then
            return flyingVehicle
        end
        return nil
    end
end
