local RESOURCE_NAME = GetCurrentResourceName()
local ENGINE_FAILURE_GFORCE = tonumber(GetConvar('engineFailureGForce', '1.0'))
local PERCENT_ENGINE_FAILURE_TIME = GetConvarInt('percentEngineFailureTime', '25') / 100
local data = {
    timer = 0,
    curentSpeed = 0.0,
    failure = false
}

local lopped = function (vehicle, data)
    local model = GetEntityModel(vehicle)

    if not IsThisModelABicycle(model) then
        local engineHealth = GetVehicleEngineHealth(vehicle)
        local engineHealthPercent = (engineHealth * 100 / 1000) / 100
        if engineHealthPercent < 0.0 then
            engineHealthPercent = 0.0
        end
        local prevSpeed = data.curentSpeed
        data.curentSpeed = GetEntitySpeed(vehicle)
        local gForce = (prevSpeed - data.curentSpeed) / 9.8

        if not data.failure and gForce > ENGINE_FAILURE_GFORCE then
            local failureTime = math.ceil(data.curentSpeed * gForce * PERCENT_ENGINE_FAILURE_TIME)
            data.failure = true
            exports[RESOURCE_NAME]:engineToggle(vehicle, false)
            SetVehicleUndriveable(vehicle, true)
            data.timer = GetGameTimer() + failureTime * 1000
            TriggerEvent('vehicle:engine:failed', gForce, failureTime, exports[RESOURCE_NAME]:getLocale().message.accident)
        elseif data.failure and GetGameTimer() >= data.timer then
            data.failure = false
            SetVehicleUndriveable(vehicle, false)
            exports[RESOURCE_NAME]:engineToggle(vehicle, true)
        end

        if engineHealth > 200 then
            SetVehicleCheatPowerIncrease(vehicle, engineHealthPercent)
        elseif engineHealth < 200 then
            SetVehicleCheatPowerIncrease(vehicle, 0.2)
        end
    end
    return data
end

exports[RESOURCE_NAME]:registerFunction('engine', data, nil, lopped, nil)

exports('engineToggle', function(vehicle, state)
    if GetIsVehicleEngineRunning(vehicle) and not state then
        SetVehicleEngineOn(vehicle, false, true, true)
    elseif not GetIsVehicleEngineRunning(vehicle) and state then
        SetVehicleEngineOn(vehicle, true, false, false)
    end
end)
