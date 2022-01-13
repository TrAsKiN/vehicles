local WINDOWS_SYSTEM = GetConvarInt('windowsSystem', 1)
local WINDOWS_INPUT = GetConvar('windowsInput', 'J')

if WINDOWS_SYSTEM then
    local windows = false

    RegisterCommand('vehicle:windows:toggle', function()
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle and GetPedInVehicleSeat(vehicle, -1) == playerPed then
            windows = not windows
            TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'windows', windows)
        end
    end, true)
    RegisterKeyMapping('vehicle:windows:toggle', exports[RESOURCE_NAME]:getLocale().input.windows, 'KEYBOARD', WINDOWS_INPUT)

    AddEventHandler('vehicle:data:synced', function (vehicles)
        for vehicleId, vehicleData in pairs(vehicles) do
            local vehicle = NetToVeh(vehicleId)
            if IsEntityAVehicle(vehicle) then
                if type(vehicleData.windows) ~= 'nil' then
                    if vehicleData.windows then
                        RollDownWindow(vehicle, 0)
                        RollDownWindow(vehicle, 1)
                    else
                        RollUpWindow(vehicle, 0)
                        RollUpWindow(vehicle, 1)
                    end
                end
            end
        end
    end)
end
