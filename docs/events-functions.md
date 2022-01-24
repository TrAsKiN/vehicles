---
title: Events and functions
nav_order: 5
---

# Triggered events

## Client-side events

- `vehicle:player:entered`
  - *vehicle*: number
- `vehicle:player:left`
  - *vehicle*: number
- `vehicle:player:fastened`
  - *message*: string
- `vehicle:engine:failed`
  - *gForce*: number
  - *time*: integer
  - *message*: string
- `vehicle:data:sync`
  - *vehicles*: table *[vehicleNetId: vehicleData]*
- `vehicle:data:synced`
  - *vehicles*: table *[vehicleNetId: vehicleData]*

## Server-side events

- `vehicle:data:init`
- `vehicle:player:eject`
  - *velocity*: vector3
- `vehicle:data:toSync`
  - *vehicle*: number
  - *property*: string
  - *value*: any

# Useful functions

Here is a list of useful functions. To use the functions, just call them in the following ways:

- `exports.<folder name>:<function>`
- `exports['<folder name>']:<function>`

## List of functions

### Getters

- `getLocale()`: returns a table containing all texts in the selected language
- `getSeatbeltStatus()`: returns the status of the seat belt
- `getSpeedLimit()`: returns the speed limit in kilometers per hour
- `getSyncedData(vehicle)`: returns the synchronized data for the vehicle in argument or `nil` if there is no synchronized data
- `getVehicleAhead()`: returns the empty vehicle in front of the player
- `isLimited()`: returns if the limiter is activated
- `isVehicleEmpty()`: returns if the vehicle is empty

### Setters

- `engineToggle(vehicle, state)`: toggle engine status
- `registerFunction(name, data, entered, looped, exited)`: register main functions
- `resetLimiter(vehicle)`: reset the limiter
