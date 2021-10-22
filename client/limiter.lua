local speedLimit = {50, 80, 110, 130}
local targetSpeed = 0
local enabled = false

local looped = function (vehicle, data)
    local model = GetEntityModel(vehicle)
    if
        vehicle
        and exports[GetCurrentResourceName()]:isLimited()
        and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
        and not IsThisModelABicycle(model)
        and not IsThisModelABoat(model)
        and not IsThisModelAHeli(model)
        and not IsThisModelAPlane(model)
        and not IsThisModelATrain(model)
        and GetEntitySpeed(vehicle) * 3.6 < (exports[GetCurrentResourceName()]:getSpeedLimit() or 0)
    then
        SetVehicleMaxSpeed(vehicle, exports[GetCurrentResourceName()]:getSpeedLimit() / 3.6)
    end
    return data
end

local exited = function (vehicle, data)
    exports[GetCurrentResourceName()]:resetLimiter(vehicle)
    return data
end

exports[GetCurrentResourceName()]:registerVehicleFunction('limiter', nil, nil, looped, exited)

RegisterKeyMapping('vehicle:limiter:toggle', "Switch the speed limiter", 'KEYBOARD', 'O')
RegisterCommand('vehicle:limiter:toggle', function()
    if not enabled then
        enabled = true
        targetSpeed = 1
    else
        targetSpeed = targetSpeed + 1
        if targetSpeed > 4 then
            exports[GetCurrentResourceName()]:resetLimiter(GetVehiclePedIsIn(PlayerPedId(), false))
        end
    end
end, true)

exports('resetLimiter', function (vehicle)
    targetSpeed = 0
    enabled = false
    SetVehicleMaxSpeed(vehicle, 0.0)
end)

exports('getSpeedLimit', function()
    return speedLimit[targetSpeed]
end)

exports('isLimited', function()
    return enabled
end)
