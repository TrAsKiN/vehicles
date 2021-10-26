local RESOURCE_NAME = GetCurrentResourceName()
local WINDOWS_INPUT = GetConvar('windowsInput', 'J')
local windows = false

RegisterKeyMapping('vehicle:windows:toggle', exports[RESOURCE_NAME]:getLocale().input.windows, 'KEYBOARD', WINDOWS_INPUT)
RegisterCommand('vehicle:windows:toggle', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        windows = not windows
        TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'windows', windows)
    end
end, true)
