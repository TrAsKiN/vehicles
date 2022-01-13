local SIREN_SYSTEM = GetConvarInt('sirenSystem', 1)
local SIREN_TOGGLE_INPUT = GetConvar('sirenToggleInput', '')

if SIREN_SYSTEM then
    RegisterCommand('vehicle:siren:toggle', function()
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'mutedSirens', IsVehicleSirenAudioOn(vehicle))
    end, false)
    RegisterKeyMapping('vehicle:siren:toggle', exports[RESOURCE_NAME]:getLocale().input.siren, 'KEYBOARD', SIREN_TOGGLE_INPUT)
    
    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = NetToVeh(vehicleId)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.mutedSirens) ~= 'nil' then
                    SetVehicleHasMutedSirens(vehicle, vehicleData.mutedSirens)
                end
            end
        end
    end)
end
