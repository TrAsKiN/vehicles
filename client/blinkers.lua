local BLINKERS_SYSTEM = GetConvarInt('blinkersSystem', 1)
local LEFT_BLINKER_INPUT = GetConvar('leftBlinkerInput', '')
local RIGHT_BLINKER_INPUT = GetConvar('rightBlinkerInput', '')

if BLINKERS_SYSTEM then
    local function changeBlinker(side)
        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local vehicleModel = GetEntityModel(vehicle)
        if
            vehicle
            and GetPedInVehicleSeat(vehicle, -1) == playerPed
            and not IsThisModelABicycle(vehicleModel)
        then
            local indicatorLights = GetVehicleIndicatorLights(vehicle)
            local indicatorSide = side == 'left' and 1 or 2
            if indicatorLights == indicatorSide or indicatorLights == 3 then
                SetVehicleIndicatorLights(vehicle, side == 'left' and 1 or 0, false)
            else
                SetVehicleIndicatorLights(vehicle, side == 'left' and 1 or 0, true)
            end
            Entity(vehicle).state.indicatorLights = GetVehicleIndicatorLights(vehicle)
        end
    end

    AddStateBagChangeHandler('indicatorLights', nil, function(bagName, key, value, reserved, replicated)
        if type(value) == 'nil' then return end
        local vehicleId = tonumber(bagName:gsub('entity:', ''), 10)
        local vehicle = getVehicleFromNetId(vehicleId)
        if DoesEntityExist(vehicle) then
            if value == 0 then
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, false)
            elseif value == 1 then
                SetVehicleIndicatorLights(vehicle, 0, false)
                SetVehicleIndicatorLights(vehicle, 1, true)
            elseif value == 2 then
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, false)
            elseif value == 3 then
                SetVehicleIndicatorLights(vehicle, 0, true)
                SetVehicleIndicatorLights(vehicle, 1, true)
            end
        end
    end)

    RegisterCommand('vehicle:blinker:left', function()
        changeBlinker('left')
    end, false)
    RegisterKeyMapping('vehicle:blinker:left', getLocale().input.blinker.left, 'KEYBOARD', LEFT_BLINKER_INPUT)

    RegisterCommand('vehicle:blinker:right', function()
        changeBlinker('right')
    end, false)
    RegisterKeyMapping('vehicle:blinker:right', getLocale().input.blinker.right, 'KEYBOARD', RIGHT_BLINKER_INPUT)
end
