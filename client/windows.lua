local WINDOWS_SYSTEM = GetConvarInt('windowsSystem', 1)
local WINDOWS_INPUT = GetConvar('windowsInput', 'J')

if WINDOWS_SYSTEM then
    local windows = false

    RegisterCommand('vehicle:windows:toggle', function()
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if
            vehicle
            and GetPedInVehicleSeat(vehicle, -1) == playerPed
        then
            Entity(vehicle).state:set('windows', not Entity(vehicle).state.windows, true)
        end
    end, true)
    RegisterKeyMapping('vehicle:windows:toggle', getLocale().input.windows, 'KEYBOARD', WINDOWS_INPUT)

    AddStateBagChangeHandler('windows', nil, function(bagName, key, value, reserved, replicated)
        if type(value) == 'nil' then return end
        local vehicleId = tonumber(bagName:gsub('entity:', ''), 10)
        local vehicle = getVehicleFromNetId(vehicleId)
        if value then
            RollDownWindow(vehicle, 0)
            RollDownWindow(vehicle, 1)
        else
            RollUpWindow(vehicle, 0)
            RollUpWindow(vehicle, 1)
        end
    end)
end
