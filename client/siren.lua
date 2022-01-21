local SIREN_SYSTEM = GetConvarInt('sirenSystem', 1)
local SIREN_TOGGLE_INPUT = GetConvar('sirenToggleInput', '')

if SIREN_SYSTEM then
    RegisterCommand('vehicle:siren:toggle', function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'mutedSirens', IsVehicleSirenAudioOn(vehicle))
        end
    end, false)
    RegisterKeyMapping('vehicle:siren:toggle', getLocale().input.siren, 'KEYBOARD', SIREN_TOGGLE_INPUT)
    
    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = getVehicleFromNetId(vehicleId)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.mutedSirens) ~= 'nil' then
                    SetVehicleHasMutedSirens(vehicle, vehicleData.mutedSirens)
                end
            end
        end
    end)
end
