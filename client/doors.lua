local DOORS_SYSTEM = GetConvarInt('doorsSystem', 0)
local DOORS_INPUT = GetConvar('doorsInput', 'U')
local ANIMATION_DICTIONARY = 'anim@mp_player_intmenu@key_fob@'
local KEY_PROP = 'lr_prop_carkey_fob'

local hasKeyCallback = function (vehicle) return true end

if DOORS_SYSTEM then
    local function playKeyAnimation(onPed)
        while not HasAnimDictLoaded(ANIMATION_DICTIONARY) do
            RequestAnimDict(ANIMATION_DICTIONARY)
            Wait(0)
        end
        while not HasModelLoaded(KEY_PROP) do
            RequestModel(KEY_PROP)
            Wait(0)
        end
        local x, y, z = table.unpack(GetEntityCoords(onPed))
        local key = CreateObject(KEY_PROP, x, y, z + 0.2, true, true, true)
        SetEntityAsMissionEntity(key, true, true)
        AttachEntityToEntity(key, onPed, GetPedBoneIndex(onPed, 57005), 0.14, 0.04, -0.0175, -110.0, 95.0, -10.0, true, true, false, true, 1, true)
        TaskPlayAnim(onPed, ANIMATION_DICTIONARY, 'fob_click_fp', 8.0, 8.0, -1, 48, 1, false, false, false)
        CreateThread(function()
            Wait(1200)
            SetModelAsNoLongerNeeded(KEY_PROP)
            RemoveAnimDict(ANIMATION_DICTIONARY)
            DetachEntity(key, false, false)
            DeleteObject(key)
        end)
    end
    RegisterCommand('vehicle:doors:toggle', function()
        local key = nil
        local ahead = false
        local playerPed = PlayerPedId()
        local vehicle = nil
        if IsPedInAnyVehicle(playerPed) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
                vehicle = nil
            end
        else
            vehicle = getVehicleAhead()
            ahead = true
        end
        if vehicle and hasKeyCallback(vehicle) then
            if GetVehicleDoorLockStatus(vehicle) > 1 then
                if ahead then
                    playKeyAnimation(playerPed)
                    PlaySoundFromEntity(-1, 'Remote_Control_Open', playerPed, 'PI_Menu_Sounds')
                    Wait(500)
                end
                TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 1)
            else
                if ahead then
                    playKeyAnimation(playerPed)
                    PlaySoundFromEntity(-1, 'Remote_Control_Close', playerPed, 'PI_Menu_Sounds')
                    Wait(500)
                end
                SetVehicleDoorsShut(vehicle, false)
                TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 2)
            end
        end
    end, true)
    RegisterKeyMapping('vehicle:doors:toggle', getLocale().input.doors, 'KEYBOARD', DOORS_INPUT)

    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = getVehicleFromNetId(vehicleId, true)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.doors) ~= 'nil' then
                    local playerPed = PlayerPedId()
                    if
                        vehicleData.doors <= 1
                        and GetVehicleDoorLockStatus(vehicle) > 1
                        and IsPedTryingToEnterALockedVehicle(playerPed)
                        and GetVehiclePedIsTryingToEnter(playerPed) == vehicle
                    then
                        ClearPedTasks(playerPed)
                    end
                    if
                        isVehicleEmpty(vehicle)
                        and GetVehicleDoorLockStatus(vehicle) ~= vehicleData.doors
                    then
                        SetVehicleLights(vehicle, 2)
                        Wait(100)
                        SetVehicleLights(vehicle, 0)
                        Wait(100)
                        SetVehicleLights(vehicle, 2)
                        Wait(100)
                        SetVehicleLights(vehicle, 0)
                    end
                    SetVehicleDoorsLocked(vehicle, vehicleData.doors)
                end
            end
        end
    end)
end

function isVehicleEmpty(vehicle)
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2
    for seat = -1, seats do
        if not IsVehicleSeatFree(vehicle, seat, true) then
            return false
        end
    end
    return true
end

function registerHasKey(callback)
    hasKeyCallback = callback
end
