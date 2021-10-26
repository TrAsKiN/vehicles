---
title: Add features
nav_order: 4
---

# Add your own features

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
