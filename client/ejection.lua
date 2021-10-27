local RESOURCE_NAME = GetCurrentResourceName()
local SEATBELT_INPUT = GetConvar('seatbeltInput', 'I')
local EJECTION_GFORCE = tonumber(GetConvar('ejectionGForce', '2.0'))
local seatbelt = false
local data = {
    curentSpeed = 0.0,
    previousBodyVelocity = vector3(0.0, 0.0, 0.0),
    onEject = false
}

local lopped = function (vehicle, data)
    local playerPed = PlayerPedId()
    local model = GetEntityModel(vehicle)

    if not IsThisModelABike(model) and not IsThisModelABicycle(model) then
        local position = GetEntityCoords(playerPed)
        local prevSpeed = data.curentSpeed
        data.curentSpeed = GetEntitySpeed(vehicle)
        local gForce = (prevSpeed - data.curentSpeed) / 9.8
        if exports[RESOURCE_NAME]:getSeatbeltStatus() then
            DisableControlAction(0, 75, true)
            DisableControlAction(2, 75, true)
            if IsDisabledControlJustPressed(0, 75) or IsDisabledControlJustPressed(2, 75) then
                print(exports[RESOURCE_NAME]:getLocale().message.seatbelt)
            end
        elseif not data.onEject and gForce > EJECTION_GFORCE then
            TriggerServerEvent('vehicle:player:eject', data.previousBodyVelocity)
            data.onEject = true
        else
            data.onEject = false
        end
        data.previousBodyVelocity = GetEntityVelocity(vehicle)
    end
    return data
end

local exited = function (vehicle, data)
    data.curentSpeed = 0.0
    return data
end

RegisterKeyMapping('vehicle:seatbelt:toggle', exports[RESOURCE_NAME]:getLocale().input.seatbelt, 'KEYBOARD', SEATBELT_INPUT)
RegisterCommand('vehicle:seatbelt:toggle', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local model = GetEntityModel(vehicle)
    if
        IsEntityAVehicle(vehicle)
        and not IsThisModelABike(model)
        and not IsThisModelABicycle(model)
    then
        PlaySoundFrontend(-1, 'Faster_Click', 'RESPAWN_ONLINE_SOUNDSET', 1)
        seatbelt = not seatbelt
    end
end, true)

AddEventHandler('vehicle:player:left', function (vehicle)
    seatbelt = false
end)

exports('getSeatbeltStatus', function()
    return seatbelt
end)

exports[RESOURCE_NAME]:registerFunction('ejection', data, nil, lopped, exited)
