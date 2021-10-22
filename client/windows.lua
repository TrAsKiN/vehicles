local windows = false

RegisterKeyMapping('vehicle:windows:toggle', "Up/down windows", 'KEYBOARD', 'J')
RegisterCommand('vehicle:windows:toggle', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed then
        windows = not windows
        TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'windows', windows)
    end
end, true)
