local DOORS_SYSTEM = GetConvarInt('doorsSystem', 0)
local DOORS_INPUT = GetConvar('doorsInput', 'U')
local ANIMATION_DICTIONARY = 'anim@mp_player_intmenu@key_fob@'

if DOORS_SYSTEM then
    RegisterCommand('vehicle:doors:toggle', function()
        local ahead = false
        local playerPed = PlayerPedId()
        local vehicle = nil
        if IsPedInAnyVehicle(playerPed) then
            vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
            if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
                vehicle = nil
            end
        else
            vehicle = getVehicleAhead()
            ahead = true
            RequestAnimDict(ANIMATION_DICTIONARY)
            repeat Wait(100) until HasAnimDictLoaded(ANIMATION_DICTIONARY)
        end
        if vehicle then
            if GetVehicleDoorLockStatus(vehicle) > 1 then
                TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 1)
                if ahead then
                    TaskPlayAnim(playerPed, ANIMATION_DICTIONARY, 'fob_click_fp', 8.0, 8.0, -1, 48, 1, false, false, false)
                    PlaySoundFromEntity(-1, 'Launch', playerPed, 'DLC_H3_Tracker_App_Sounds')
                end
            else
                SetVehicleDoorsShut(vehicle, false)
                TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'doors', 2)
                if ahead then
                    TaskPlayAnim(playerPed, ANIMATION_DICTIONARY, 'fob_click_fp', 8.0, 8.0, -1, 48, 1, false, false, false)
                    PlaySoundFromEntity(-1, 'Close', playerPed, 'DLC_H3_Tracker_App_Sounds')
                end
            end
        end
    end, true)
    RegisterKeyMapping('vehicle:doors:toggle', getLocale().input.doors, 'KEYBOARD', DOORS_INPUT)

    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = getVehicleFromNetId(vehicleId, true)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.doors) ~= 'nil' then
                    SetVehicleDoorsLocked(vehicle, vehicleData.doors)
                end
            end
        end
    end)
end
