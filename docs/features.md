---
title: Add your features
nav_order: 4
---

# Add your own features

To add functionality, simply call the function `exports.<folder name>:registerFunction(name, data, entered, looped, exited)` with the following parameters:

- `name`: *string*
- `data`: *table*
- `entered`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed only once when the player enters a vehicle
- `looped`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed on each tick as long as the player is in a vehicle
- `exited`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed only once when the player has left a vehicle

The functions take as input the array of values defined in `data` and **must** return an array with the same structure (the values can be modified).

## Example

For the example we will integrate a simple management of the battery consumption for electric vehicles. We will assume that the installation file is `vehicles`.

Let's start by making a new module by creating a folder that we will name `battery`. Let's quickly add the file `fxmanifest.lua` in which we write these lines:

```lua
fx_version 'cerulean'
game 'gta5'

client_script 'battery.lua'
```

Let's add now in the file `server.cfg` after the line corresponding to `vehicles` :

```
ensure battery
```

### Let's get started!

We can now create the `battery.lua` file in which we will write our logic.

We will need to initialize a variable if it is non-existent when the player enters a vehicle. Then, every second, we will remove an amount from the battery level that we will calculate in relation to the engine rpm. Finally, when the player leaves the vehicle, we will synchronize the variable to the other players.

Let's start by creating the variables we will use.

```lua
local data = {
  timer = 0,
  isElectric = false,
  batteryLevel = 100.0
}
```

Now let's create the function that will be executed when entering a vehicle. This function, like the others, takes as argument the vehicle and the data provided and must return these data (which can be modified).

```lua
-- to add to previous code

local entered = function (vehicle, data)
  if not GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume') then
    data.isElectric = true
    local syncedBatteryLevel = exports.vehicles:getSyncedData(vehicle).batteryLevel
    if syncedBatteryLevel then
      data.batteryLevel = syncedBatteryLevel
    end
  end
  return data
end
```

Now let's get to the heart of our logic. We need to calculate the amount of battery consumed that we will subtract from the current amount every second.

```lua
-- to add to previous code

local looped = function (vehicle, data)
  if data.isElectric then
    local gameTimer = GetGameTimer()
    if gameTimer > data.timer then
      data.timer = gameTimer + 1000
      if data.batteryLevel > 0.0 then
        if GetIsVehicleEngineRunning(vehicle) then
          local engineRpm = GetVehicleCurrentRpm(vehicle)
          local batteryConsumption = 0.1 * engineRpm
          data.batteryLevel = data.batteryLevel - batteryConsumption
        end
        if not IsVehicleDriveable(vehicle, false) then
          SetVehicleUndriveable(vehicle, false)
        end
      elseif data.batteryLevel <= 0.0 then
        if GetIsVehicleEngineRunning(vehicle) then
          SetVehicleEngineOn(vehicle, false, true, true)
        end
        if IsVehicleDriveable(vehicle, false) then
          SetVehicleUndriveable(vehicle, true)
        end
      end
    end
  end
  return data
end
```

And that's it! Let's not forget to synchronize the battery data of the vehicle when the player leaves it with the event `vehicle:data:toSync` and to reset the variables.

```lua
-- to add to previous code

local exited = function (vehicle, data)
  TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'batteryLevel', data.batteryLevel)
  data.isElectric = false
  data.batteryLevel = 100.0
  return data
end
```

All that remains is to register our data and functions so that they are taken into account.

```lua
-- to add to previous code

exports.vehicles:registerFunction('battery', data, entered, looped, exited)
```

This code is only an example and is far from perfect. Do not hesitate to appropriate it or to be inspired by it.

## Full code

```lua
-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

client_script 'battery.lua'
```

```lua
-- battery.lua
local data = {
  timer = 0,
  isElectric = false,
  batteryLevel = 100.0
}

local entered = function (vehicle, data)
  if not GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume') then
    data.isElectric = true
    local syncedBatteryLevel = exports.vehicles:getSyncedData(vehicle).batteryLevel
    if syncedBatteryLevel then
      data.batteryLevel = syncedBatteryLevel
    end
  end
  return data
end

local looped = function (vehicle, data)
  if data.isElectric then
    local gameTimer = GetGameTimer()
    if gameTimer > data.timer then
      data.timer = gameTimer + 1000
      if data.batteryLevel > 0.0 then
        if GetIsVehicleEngineRunning(vehicle) then
          local engineRpm = GetVehicleCurrentRpm(vehicle)
          local batteryConsumption = 0.1 * engineRpm
          data.batteryLevel = data.batteryLevel - batteryConsumption
        end
        if not IsVehicleDriveable(vehicle, false) then
          SetVehicleUndriveable(vehicle, false)
        end
      elseif data.batteryLevel <= 0.0 then
        if GetIsVehicleEngineRunning(vehicle) then
          SetVehicleEngineOn(vehicle, false, true, true)
        end
        if IsVehicleDriveable(vehicle, false) then
          SetVehicleUndriveable(vehicle, true)
        end
      end
    end
  end
  return data
end

local exited = function (vehicle, data)
  TriggerServerEvent('vehicle:data:toSync', VehToNet(vehicle), 'batteryLevel', data.batteryLevel)
  data.isElectric = false
  data.batteryLevel = 100.0
  return data
end

exports.vehicles:registerFunction('battery', data, entered, looped, exited)
```
