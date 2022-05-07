local LIMITER_SYSTEM = GetConvarInt('limiterSystem', 1)
local LIMITER_INPUT = GetConvar('limiterInput', 'O')
local SPEED_LIMIT = json.decode(GetConvar('speedLimit', '[50, 80, 110, 130]'))

local targetSpeed = 0

if LIMITER_SYSTEM then
    local looped = function (vehicle, data)
        local model = GetEntityModel(vehicle)
        if
            vehicle
            and isLimited()
            and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
            and not IsThisModelABicycle(model)
            and not IsThisModelABoat(model)
            and not IsThisModelAHeli(model)
            and not IsThisModelAPlane(model)
            and not IsThisModelATrain(model)
            and GetEntitySpeed(vehicle) * 3.6 < (getSpeedLimit() or 0)
        then
            SetVehicleMaxSpeed(vehicle, getSpeedLimit() / 3.6)
        end
        return data
    end
    
    local exited = function (vehicle, data)
        resetLimiter(vehicle)
        return data
    end
    
    registerFunction('limiter', nil, nil, looped, exited)
    
    RegisterCommand('vehicle:limiter:toggle', function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            targetSpeed = targetSpeed + 1
            if targetSpeed > #SPEED_LIMIT then
                resetLimiter(vehicle)
            end
        end
    end, true)
    RegisterKeyMapping('vehicle:limiter:toggle', getLocale().input.limiter, 'KEYBOARD', LIMITER_INPUT)
end

function resetLimiter(vehicle)
    targetSpeed = 0
    SetVehicleMaxSpeed(vehicle, 0.0)
end

function getSpeedLimit()
    return SPEED_LIMIT[targetSpeed]
end

function isLimited()
    if targetSpeed then
        return true
    end
    return false
end

exports('getSpeedLimit', getSpeedLimit)
exports('isLimited', isLimited)
exports('resetLimiter', resetLimiter)
