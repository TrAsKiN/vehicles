---
title: Customization
nav_order: 3
---

# `server.cfg` variables

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

## Change keyboard keys

The allowed keyboard keys are listed [here](https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/).

- `set leftBlinkerInput ''`
- `set rightBlinkerInput ''`
- `set seatbeltInput 'I'`
- `set limiterInput 'O'`
- `set sirenToggleInput ''`
- `set windowsInput 'J'`

# Add features

To add functionality, simply call the function `exports.<folder name>:registerVehicleFunction(name, data, entered, looped, exited)` with the following parameters:

- `name`: *string*
- `data`: *table*
- `entered`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed only once when the player enters a vehicle
- `looped`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed on each tick as long as the player is in a vehicle
- `exited`: *function(`vehicle`, `data`)* or *nil*
  - This function is executed only once when the player has left a vehicle

The functions take as input the array of values defined in `data` and **must** return an array with the same structure (the values can be modified).
