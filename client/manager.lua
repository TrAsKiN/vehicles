local vehicleHandlings = json.decode(LoadResourceFile(GetCurrentResourceName(), 'data/vehicleHandlings.json'))
local registeredFunctions = {}
local COLLISION_DAMAGE_MULTIPLIER = tonumber(GetConvar('collisionDamageMultiplier', '4.0'))
local DEFORMATION_DAMAGE_MULTIPLIER = tonumber(GetConvar('deformationDamageMultiplier', '1.25'))
local ENGINE_DAMAGE_MULTIPLIER = tonumber(GetConvar('engineDamageMultiplier', '2.0'))
local DISABLE_RADAR = tonumber(GetConvar('disableRadar', '1'))
local DISABLE_RADIO = tonumber(GetConvar('disableRadio', '0'))
local MAX_ROLL = tonumber(GetConvar('maxRoll', '80.0'))
local PERSIST_STOLEN = tonumber(GetConvar('persistStolen', '0'))
local LOCALE = GetConvar('lang', 'en')

local locale = json.decode(LoadResourceFile(GetCurrentResourceName(), 'locale/en.json'))
local localeFile = LoadResourceFile(GetCurrentResourceName(), 'locale/'.. LOCALE ..'.json')
if localeFile then
    locale = json.decode(localeFile)
end

AddEventHandler('gameEventTriggered', function (name, data)
    if name == 'CEventNetworkPlayerEnteredVehicle' then
        local player, vehicle = table.unpack(data)
        if player == PlayerId() then
            TriggerEvent('vehicle:player:entered', vehicle)
        end
    end
end)

AddEventHandler('vehicle:player:entered', function (vehicle)
    local playerPed = PlayerPedId()
    local model = GetEntityModel(vehicle)
    if not IsEntityAMissionEntity(vehicle) and PERSIST_STOLEN then
        SetEntityAsMissionEntity(vehicle, true, true)
    end
    for _, veh in pairs(vehicleHandlings) do
        if GetHashKey(veh['Id']) == model then
            local fCollisionDamageMult = tonumber(string.format("%.2f", GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult')))
            local fDeformationDamageMult = tonumber(string.format("%.2f", GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult')))
            local fEngineDamageMult = tonumber(string.format("%.2f", GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fEngineDamageMult')))
            if 
                veh['CollisionDamageMult'] == fCollisionDamageMult
                and veh['DeformationDamageMult'] == fDeformationDamageMult
                and veh['EngineDamageMult'] == fEngineDamageMult
            then
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fCollisionDamageMult', fCollisionDamageMult * COLLISION_DAMAGE_MULTIPLIER)
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fDeformationDamageMult', fDeformationDamageMult * DEFORMATION_DAMAGE_MULTIPLIER)
                SetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fEngineDamageMult', fEngineDamageMult * ENGINE_DAMAGE_MULTIPLIER)
            end
        end
    end
    RollUpWindow(vehicle, 0)
    RollUpWindow(vehicle, 1)
    if DISABLE_RADAR then
        DisplayRadar(true)
    end
    SetVehicleRadioEnabled(vehicle, not DISABLE_RADIO)
    for name, vehFunction in pairs(registeredFunctions) do
        if vehFunction.entered then
            registeredFunctions[name].data = vehFunction.entered(vehicle, registeredFunctions[name].data)
        end
    end
    CreateThread(function ()
        while true do
            local roll = GetEntityRoll(vehicle)
            if not IsPedInAnyVehicle(playerPed) then
                if DISABLE_RADAR then
                    DisplayRadar(false)
                end
                TriggerEvent('vehicle:player:left', vehicle)
                for name, vehFunction in pairs(registeredFunctions) do
                    if vehFunction.exited then
                        registeredFunctions[name].data = vehFunction.exited(vehicle, registeredFunctions[name].data)
                    end
                end
                return
            end
            if GetPedInVehicleSeat(vehicle, -1) == playerPed
                and (IsEntityInAir(vehicle) or roll > MAX_ROLL or roll < -MAX_ROLL)
                and not IsThisModelABoat(model)
                and not IsThisModelAHeli(model)
                and not IsThisModelAJetski(model)
                and not IsThisModelAPlane(model)
            then
                DisableControlAction(0, 59, true)
                DisableControlAction(0, 60, true)
            end
            for name, vehFunction in pairs(registeredFunctions) do
                if vehFunction.looped then
                    registeredFunctions[name].data = vehFunction.looped(vehicle, registeredFunctions[name].data)
                end
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('vehicle:data:sync')
AddEventHandler('vehicle:data:sync', function(vehicles)
    for vehicleId, vehicleData in pairs(vehicles) do
        local vehicle = NetToVeh(vehicleId)
        if vehicle and GetEntityType(vehicle) == 2 then
            if vehicleData.windows then
                RollDownWindow(vehicle, 0)
                RollDownWindow(vehicle, 1)
            else
                RollUpWindow(vehicle, 0)
                RollUpWindow(vehicle, 1)
            end
            SetVehicleHasMutedSirens(vehicle, vehicleData.mutedSirens)
            SetVehicleFuelLevel(vehicle, vehicleData.fuelLevel)
            if vehicleData.indicatorLights == 0 then
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
            elseif vehicleData.indicatorLights == 1 then
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, true)
            elseif vehicleData.indicatorLights == 2 then
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, false)
            elseif vehicleData.indicatorLights == 3 then
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
            end
        end
    end
end)

exports('registerVehicleFunction', function (name, data, entered, looped, exited)
    if not registeredFunctions[name] then
        registeredFunctions[name] = {
            data = data,
            entered = entered,
            looped = looped,
            exited = exited
        }
    end
end)

exports('getLocale', function ()
    return locale
end)
