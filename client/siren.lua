local SIREN_SYSTEM = GetConvarInt('sirenSystem', 1)
local SIREN_TOGGLE_INPUT = GetConvar('sirenToggleInput', '')

if SIREN_SYSTEM then
    RegisterCommand('vehicle:siren:toggle', function()
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if GetPedInVehicleSeat(vehicle, -1) == playerPed then
            Entity(vehicle).state:set('mutedSirens', IsVehicleSirenAudioOn(vehicle), true)
        end
    end, false)
    RegisterKeyMapping('vehicle:siren:toggle', getLocale().input.siren, 'KEYBOARD', SIREN_TOGGLE_INPUT)

    AddStateBagChangeHandler('mutedSirens', nil, function(bagName, key, value, reserved, replicated)
        if type(value) == 'nil' then return end
        local vehicleId = tonumber(bagName:gsub('entity:', ''), 10)
        local vehicle = getVehicleFromNetId(vehicleId, true)
        SetVehicleHasMutedSirens(vehicle, value)
    end)
end
