local ENGINE_FAILURE_GFORCE = tonumber(GetConvar('engineFailureGForce', 1.0))
local PERCENT_ENGINE_FAILURE_TIME = tonumber(GetConvar('percentEngineFailureTime', 25)) / 100
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
            TriggerEvent('vehicle:engine:toggle', false)
            SetVehicleUndriveable(vehicle, true)
            data.timer = GetGameTimer() + failureTime * 1000
            print("Accident! Impact force: ".. string.format('%.2f', gForce) .."g, Engine stop time: ".. failureTime .."s.")
        elseif data.failure and GetGameTimer() >= data.timer then
            data.failure = false
            SetVehicleUndriveable(vehicle, false)
            TriggerEvent('vehicle:engine:toggle', true)
        end

        if engineHealth < 900 and engineHealth > 200 then
            SetVehicleCheatPowerIncrease(vehicle, engineHealthPercent)
        elseif engineHealth < 200 then
            SetVehicleCheatPowerIncrease(vehicle, 0.2)
        end
    end
    return data
end

exports[GetCurrentResourceName()]:registerVehicleFunction('engine', data, nil, lopped, nil)

AddEventHandler('vehicle:engine:toggle', function(state)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if GetIsVehicleEngineRunning(vehicle) and not state then
        SetVehicleEngineOn(vehicle, false, true, true)
    else
        SetVehicleEngineOn(vehicle, true, false, false)
    end
end)
