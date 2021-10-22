# Customizable vehicle management for FiveM

Configure and manage your server's vehicles simply via variables in your `server.cfg`.

## Features

- [x] Event-based activation
- [x] Thread removal outside the vehicle
- [x] Customization via `server.cfg`
- [x] Possibility to add your own functions easily
- [x] Synchronization and realistic vehicle management
  - [x] Persistent stolen vehicles
  - [x] Fuel consumption
  - [x] Engine failure
  - [x] Engine power based on engine health
  - [x] Server-side ejection
  - [x] Safety belt
  - [x] Speed limiter
  - [x] Blinkers
  - [x] Windows
  - [x] Mute sirens

## Customization

### `server.cfg` variables

- `set ejectionGForce 2.0`
- `set engineFailureGForce 1.0`
- `set percentEngineFailureTime 25`
- `set fuelComsumptionPerSecond 0.08`
- `set fuelComsumptionMultiplierOnReserve 1.2`
- `set fuelComsumptionMultiplierWhenEngineSmokes 1.5`
- `set fuelComsumptionMultiplierWhenEngineFails 2.0`
- `set fuelComsumptionMultiplierWhenTankLeak 25.0`
- `set collisionDamageMultiplier 4.0`
- `set deformationDamageMultiplier 1.25`
- `set engineDamageMultiplier 2.0`
- `set disableRadar 1`
- `set disableRadio 0`
- `set maxRoll 80.0`
- `set persistStolen 0`

### Add features

To add functionality, simply call the function `exports.vehicles:registerVehicleFunction(name, data, entered, looped, exited)` with the following parameters:

- `name`: *string*
- `data`: *table*
- `entered`: *function(`vehicle`, `data`)* or *nil*
- `looped`: *function(`vehicle`, `data`)* or *nil*
- `exited`: *function(`vehicle`, `data`)* or *nil*

The functions take as input the array of values defined in `data` and **must** return an array with the same structure (the values can be modified).

### Triggered events

#### Client-side events

- `vehicle:player:entered`
  - *vehicle*: number
- `vehicle:player:left`
  - *vehicle*: number
- `vehicle:data:sync`
  - *vehicles*: table

#### Server-side events

- `vehicle:player:eject`
  - *velocity*: vector3
- `vehicle:data:toSync`
  - *vehicle*: number
  - *property*: string
  - *value*: any

### Useful functions

Here is a list of useful functions. To use the functions, just call them in the following ways:

- `exports.<folder name>:<function>`
- `exports['<folder name>']:<function>`

#### List of functions

- `getSeatbeltStatus()`: returns the status of the seat belt
- `getSpeedLimit()`: returns the speed limit in kilometers per second
- `isLimited()`: returns if the limiter is activated
