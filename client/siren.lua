local RESOURCE_NAME = GetCurrentResourceName()
local SIREN_TOGGLE_INPUT = GetConvar('sirenToggleInput', '')

RegisterCommand('vehicle:siren:toggle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'mutedSirens', IsVehicleSirenAudioOn(vehicle))
end, false)
RegisterKeyMapping('vehicle:siren:toggle', exports[RESOURCE_NAME]:getLocale().input.siren, 'KEYBOARD', SIREN_TOGGLE_INPUT)
