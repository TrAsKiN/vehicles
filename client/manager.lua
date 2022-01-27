RESOURCE_NAME = GetCurrentResourceName()

local VEHICLE_HANDLINGS = json.decode(LoadResourceFile(RESOURCE_NAME, 'data/vehicleHandlings.json'))
local COLLISION_DAMAGE_MULTIPLIER = tonumber(GetConvar('collisionDamageMultiplier', '4.0'))
local DEFORMATION_DAMAGE_MULTIPLIER = tonumber(GetConvar('deformationDamageMultiplier', '1.25'))
local ENGINE_DAMAGE_MULTIPLIER = tonumber(GetConvar('engineDamageMultiplier', '2.0'))
local DISABLE_RADAR = GetConvarInt('disableRadar', 1)
local DISABLE_RADIO = GetConvarInt('disableRadio', 0)
local MAX_ROLL = tonumber(GetConvar('maxRoll', '80.0'))
local PERSIST_STOLEN = GetConvarInt('persistStolen', 0)
local LANG = GetConvar('lang', 'en')

local vehiclesData = {}
local registeredFunctions = {}
local hasGpsCallback = function () return true end

local locale = nil
local localeFile = LoadResourceFile(RESOURCE_NAME, 'locale/'.. LANG ..'.json')
if localeFile then
    locale = json.decode(localeFile)
else
    locale = json.decode(LoadResourceFile(RESOURCE_NAME, 'locale/en.json'))
end

AddEventHandler('onClientResourceStart', function (resource)
    if resource == RESOURCE_NAME then
        TriggerServerEvent('vehicle:data:init')
        repeat Wait(100) until IsMinimapRendering()
        if DISABLE_RADAR then
            log.debug("Disabling radar...")
            DisplayRadar(false)
        end
    end
end)

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
    if PERSIST_STOLEN and not IsEntityAMissionEntity(vehicle) then
        SetEntityAsMissionEntity(vehicle, true, true)
    end
    for _, veh in pairs(VEHICLE_HANDLINGS) do
        if GetHashKey(veh['Id']) == GetDisplayNameFromVehicleModel(model) then
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
    if DISABLE_RADAR and hasGps() then
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
                if DISABLE_RADAR and not IsRadarHidden() then
                    DisplayRadar(false)
                end
                for name, vehFunction in pairs(registeredFunctions) do
                    if vehFunction.exited then
                        registeredFunctions[name].data = vehFunction.exited(vehicle, registeredFunctions[name].data)
                    end
                end
                TriggerEvent('vehicle:player:left', vehicle)
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
AddEventHandler('vehicle:data:sync', function (vehicles)
    vehiclesData = vehicles
    TriggerEvent('vehicle:data:synced', vehiclesData)
end)

function registerFunction(name, data, entered, looped, exited)
    if not registeredFunctions[name] then
        registeredFunctions[name] = {
            data = data,
            entered = entered,
            looped = looped,
            exited = exited
        }
    end
end

function registerHasGps(callback)
    hasGpsCallback = callback
end

function getSyncedData(vehicle)
    if vehiclesData[VehToNet(vehicle)] then
        return vehiclesData[VehToNet(vehicle)]
    end
    return nil
end

function getLocale()
    return locale
end

function getVehicleAhead()
    local LAND_EMPTY_VEHICLES = 131075
    local FLYING_EMPTY_VEHICLES = 28675
    local RADIUS = 2.75
    local MODEL = 0
    local playerPed = PlayerPedId()
    local position = GetEntityCoords(playerPed) + GetEntityForwardVector(playerPed) * 1.66
    if IsAnyVehicleNearPoint(position, RADIUS) then
        local landVehicle = GetClosestVehicle(position, RADIUS, MODEL, LAND_EMPTY_VEHICLES)
        if IsEntityAVehicle(landVehicle) then
            return landVehicle
        end
        local flyingVehicle = GetClosestVehicle(position, RADIUS, MODEL, FLYING_EMPTY_VEHICLES)
        if IsEntityAVehicle(flyingVehicle) then
            return flyingVehicle
        end
        return nil
    end
end

function getVehicleFromNetId(netId, force)
    if NetworkDoesNetworkIdExist(netId) then
        local vehicle = NetToVeh(netId)
        if force or GetPedInVehicleSeat(vehicle, -1) ~= PlayerPedId() then
            return vehicle
        end
    end
    return nil
end

function hasGps()
    return hasGpsCallback()
end
