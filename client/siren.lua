local SIREN_TOGGLE_INPUT = GetConvar('sirenToggleInput', '')

RegisterCommand('vehicle:siren:toggle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'mutedSirens', IsVehicleSirenAudioOn(vehicle))
end, false)
RegisterKeyMapping('vehicle:siren:toggle', "Toggle siren sound", 'KEYBOARD', SIREN_TOGGLE_INPUT)
