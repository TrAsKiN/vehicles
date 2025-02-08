local ENGINE_SYSTEM = GetConvarInt('engineSystem', 1)
local ENGINE_FAILURE_GFORCE = tonumber(GetConvar('engineFailureGForce', '1.0'))
local PERCENT_ENGINE_FAILURE_TIME = GetConvarInt('percentEngineFailureTime', 25) / 100

if ENGINE_SYSTEM then
    local data = {
        timer = 0,
        curentSpeed = 0.0,
        failure = false
    }

    local lopped = function(vehicle, data)
        local model = GetEntityModel(vehicle)
        if
            not IsThisModelABicycle(model)
            and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
        then
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
                engineToggle(vehicle, false, {
                    instantly = true,
                    preventRestart = true,
                })
                data.timer = GetGameTimer() + failureTime * 1000
                TriggerEvent('vehicle:engine:failed', gForce, failureTime,
                    string.format(getLocale().message.accident, gForce, failureTime))
            elseif data.failure and GetGameTimer() >= data.timer then
                data.failure = false
                engineToggle(vehicle, true)
            end

            if engineHealth > 200 then
                SetVehicleCheatPowerIncrease(vehicle, engineHealthPercent)
            elseif engineHealth < 200 then
                SetVehicleCheatPowerIncrease(vehicle, 0.2)
            end
        end
        return data
    end

    registerFunction('engine', data, nil, lopped, nil)
end

function engineToggle(vehicle, state, options)
    if options == nil then
        options = {}
    end
    if options.instantly == nil then
        options.instantly = false
    end
    if options.preventRestart == nil then
        options.preventRestart = false
    end
    SetVehicleEngineOn(vehicle, state, options.instantly, options.preventRestart)
    if options.halt then
        BringVehicleToHalt(vehicle, options.halt, 1, false)
    end
    if not state and options.preventRestart then
        SetPedConfigFlag(PlayerPedId(), 429, true)  -- CPED_CONFIG_FLAG_DisableStartEngine
    else
        SetPedConfigFlag(PlayerPedId(), 429, false) -- CPED_CONFIG_FLAG_DisableStartEngine
    end
end

exports('engineToggle', engineToggle)
