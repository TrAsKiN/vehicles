local RESOURCE_NAME = GetCurrentResourceName()
local LEFT_BLINKER_INPUT = GetConvar('leftBlinkerInput', '')
local RIGHT_BLINKER_INPUT = GetConvar('rightBlinkerInput', '')

function changeBlinker(side)
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
        TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'indicatorLights', GetVehicleIndicatorLights(vehicle))
    end
end

RegisterCommand('vehicle:blinker:left', function()
    changeBlinker('left')
end, false)
RegisterKeyMapping('vehicle:blinker:left', exports[RESOURCE_NAME]:getLocale().input.blinker.left, 'KEYBOARD', LEFT_BLINKER_INPUT)

RegisterCommand('vehicle:blinker:right', function()
    changeBlinker('right')
end, false)
RegisterKeyMapping('vehicle:blinker:right', exports[RESOURCE_NAME]:getLocale().input.blinker.right, 'KEYBOARD', RIGHT_BLINKER_INPUT)
