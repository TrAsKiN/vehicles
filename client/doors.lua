local DOORS_SYSTEM = GetConvarInt('doorsSystem', 0)
local DOORS_INPUT = GetConvar('doorsInput', 'U')

local hasKeyCallback = function (vehicle) return true end

if DOORS_SYSTEM then
    RegisterCommand('vehicle:doors:toggle', function()
        local key = nil
        local ahead = false
        local playerPed = PlayerPedId()
        local vehicle = nil
        if IsPedInAnyVehicle(playerPed) then
            vehicle = GetVehiclePedIsIn(playerPed, false)
            if GetPedInVehicleSeat(vehicle, -1) ~= playerPed then
                vehicle = nil
            end
        else
            vehicle = getVehicleAhead()
            ahead = true
        end
        if vehicle and hasKeyCallback(vehicle) then
            control(vehicle, function ()
                if GetVehicleDoorLockStatus(vehicle) > 1 then
                    if ahead then
                        playKeyAnimation(playerPed)
                        PlaySoundFromEntity(-1, 'Remote_Control_Open', playerPed, 'PI_Menu_Sounds')
                        Wait(500)
                    end
                    Entity(vehicle).state:set('doors', 1, true)
                else
                    if ahead then
                        playKeyAnimation(playerPed)
                        PlaySoundFromEntity(-1, 'Remote_Control_Close', playerPed, 'PI_Menu_Sounds')
                        Wait(500)
                    end
                    SetVehicleDoorsShut(vehicle, false)
                    Entity(vehicle).state:set('doors', 2, true)
                end
            end)
        end
    end, true)
    RegisterKeyMapping('vehicle:doors:toggle', getLocale().input.doors, 'KEYBOARD', DOORS_INPUT)

    AddStateBagChangeHandler('doors', nil, function(bagName, key, value, reserved, replicated)
        if type(value) == 'nil' then return end
        local vehicleId = tonumber(bagName:gsub('entity:', ''), 10)
        local vehicle = getVehicleFromNetId(vehicleId, true)
        local playerPed = PlayerPedId()
        if
            value <= 1
            and GetVehicleDoorLockStatus(vehicle) > 1
            and IsPedTryingToEnterALockedVehicle(playerPed)
            and GetVehiclePedIsTryingToEnter(playerPed) == vehicle
        then
            ClearPedTasks(playerPed)
        end
        if
            isVehicleEmpty(vehicle)
            and GetVehicleDoorLockStatus(vehicle) ~= value
        then
            SetVehicleLights(vehicle, 2)
            Wait(100)
            SetVehicleLights(vehicle, 0)
            Wait(100)
            SetVehicleLights(vehicle, 2)
            Wait(100)
            SetVehicleLights(vehicle, 0)
        end
        SetVehicleDoorsLocked(vehicle, value)
    end)
end

function isVehicleEmpty(vehicle)
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2
    for seat = -1, seats do
        if not IsVehicleSeatFree(vehicle, seat, true) then
            return false
        end
    end
    return true
end

function registerHasKey(callback)
    hasKeyCallback = callback
end

exports('isVehicleEmpty', isVehicleEmpty)
exports('registerHasKey', registerHasKey)
