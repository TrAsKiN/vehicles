local FUEL_SYSTEM = GetConvarInt('fuelSystem', 1)
local FUEL_COMSUMPTION_PER_SECOND = tonumber(GetConvar('fuelComsumptionPerSecond', '0.08'))
local FUEL_COMSUMPTION_MULTIPLIER_ON_RESERVE = tonumber(GetConvar('fuelComsumptionMultiplierOnReserve', '1.2'))
local FUEL_COMSUMPTION_MULTIPLIER_WHEN_ENGINE_SMOKES = tonumber(GetConvar('fuelComsumptionMultiplierWhenEngineSmokes', '1.5'))
local FUEL_COMSUMPTION_MULTIPLIER_WHEN_ENGINE_FAILS = tonumber(GetConvar('fuelComsumptionMultiplierWhenEngineFails', '2.0'))
local FUEL_COMSUMPTION_MULTIPLIER_WHEN_TANK_LEAK = tonumber(GetConvar('fuelComsumptionMultiplierWhenTankLeak', '25.0'))

if FUEL_SYSTEM then
    local data = {
        timer = 0,
        initialFuelLevel = 0.0,
        maxFuelLevel = 0.0
    }
    
    local entered = function (vehicle, data)
        data.initialFuelLevel = GetVehicleFuelLevel(vehicle)
        data.maxFuelLevel = GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume') or data.initialFuelLevel
        if
            data.maxFuelLevel > 0
            and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
        then
            if data.initialFuelLevel == data.maxFuelLevel then
                SetVehicleFuelLevel(vehicle, math.random(2, math.round(data.maxFuelLevel)) + 0.0)
            end
        end
        return data
    end
    
    local looped = function (vehicle, data)
        if
            data.maxFuelLevel > 0
            and GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
        then
            local gameTimer = GetGameTimer()
            if gameTimer > data.timer then
                data.timer = gameTimer + 1000
                local model = GetEntityModel(vehicle)
                local engineHealth = GetVehicleEngineHealth(vehicle)
                local fuelLevel = GetVehicleFuelLevel(vehicle)
                local tankHealth = GetVehiclePetrolTankHealth(vehicle)
                local fuelPercent = (fuelLevel * 100) / data.maxFuelLevel

                if GetIsVehicleEngineRunning(vehicle) then
                    local engineRpm = GetVehicleCurrentRpm(vehicle)
                    local acceleration = GetVehicleModelAcceleration(model)
                    local baseConsumption = FUEL_COMSUMPTION_PER_SECOND
                    if IsThisModelABoat(model) then
                        baseConsumption = baseConsumption / 10
                    end
                    local consumptionMultiplier = 1.0
                    if acceleration < 1.0 then
                        consumptionMultiplier = consumptionMultiplier + acceleration
                    elseif acceleration >= 1.0 then
                        consumptionMultiplier = consumptionMultiplier + 1.0
                    end
                    if fuelPercent <= 10 then
                        consumptionMultiplier = consumptionMultiplier * FUEL_COMSUMPTION_MULTIPLIER_ON_RESERVE
                    end
                    if engineHealth <= 400 and engineHealth > 300 then
                        consumptionMultiplier = consumptionMultiplier * FUEL_COMSUMPTION_MULTIPLIER_WHEN_ENGINE_SMOKES
                    elseif engineHealth <= 300 and engineHealth > 0 then
                        consumptionMultiplier = consumptionMultiplier * FUEL_COMSUMPTION_MULTIPLIER_WHEN_ENGINE_FAILS
                    end
                    if tankHealth <= 650 then
                        consumptionMultiplier = consumptionMultiplier * FUEL_COMSUMPTION_MULTIPLIER_WHEN_TANK_LEAK
                    end
                    local consumption = (baseConsumption * consumptionMultiplier) * engineRpm
                    SetVehicleFuelLevel(vehicle, fuelLevel - consumption)
                end
            end
        end
        return data
    end
    
    local exited = function (vehicle, data)
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'fuelLevel', GetVehicleFuelLevel(vehicle))
        end
        return data
    end
    
    exports[RESOURCE_NAME]:registerFunction('fuel', data, entered, looped, exited)
    
    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = getVehicleFromNetId(vehicleId)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.fuelLevel) ~= 'nil' then
                    SetVehicleFuelLevel(vehicle, vehicleData.fuelLevel)
                end
            end
        end
    end)
end
