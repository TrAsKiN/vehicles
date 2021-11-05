local RESOURCE_NAME = GetCurrentResourceName()
local LIMITER_INPUT = GetConvar('limiterInput', 'O')
local SPEED_LIMIT = json.decode(GetConvar('speedLimit', '[50, 80, 110, 130]'))
local targetSpeed = 0

local looped = function (vehicle, data)
    local model = GetEntityModel(vehicle)
    if
        vehicle
        and exports[RESOURCE_NAME]:isLimited()
        and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
        and not IsThisModelABicycle(model)
        and not IsThisModelABoat(model)
        and not IsThisModelAHeli(model)
        and not IsThisModelAPlane(model)
        and not IsThisModelATrain(model)
        and GetEntitySpeed(vehicle) * 3.6 < (exports[RESOURCE_NAME]:getSpeedLimit() or 0)
    then
        SetVehicleMaxSpeed(vehicle, exports[RESOURCE_NAME]:getSpeedLimit() / 3.6)
    end
    return data
end

local exited = function (vehicle, data)
    exports[RESOURCE_NAME]:resetLimiter(vehicle)
    return data
end

exports[RESOURCE_NAME]:registerFunction('limiter', nil, nil, looped, exited)

RegisterKeyMapping('vehicle:limiter:toggle', exports[RESOURCE_NAME]:getLocale().input.limiter, 'KEYBOARD', LIMITER_INPUT)
RegisterCommand('vehicle:limiter:toggle', function()
    targetSpeed = targetSpeed + 1
    if targetSpeed > #SPEED_LIMIT then
        exports[RESOURCE_NAME]:resetLimiter(GetVehiclePedIsIn(PlayerPedId(), false))
    end
end, true)

exports('resetLimiter', function (vehicle)
    targetSpeed = 0
    SetVehicleMaxSpeed(vehicle, 0.0)
end)

exports('getSpeedLimit', function()
    return SPEED_LIMIT[targetSpeed]
end)

exports('isLimited', function()
    if targetSpeed then
        return true
    end
    return false
end)
