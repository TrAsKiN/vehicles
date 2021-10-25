---
title: Events and functions
nav_order: 3
---

# Triggered events

## Client-side events

- `vehicle:player:entered`
  - *vehicle*: number
- `vehicle:player:left`
  - *vehicle*: number
- `vehicle:data:sync`
  - *vehicles*: table

## Server-side events

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

- `getSeatbeltStatus()`: returns the status of the seat belt
- `getSpeedLimit()`: returns the speed limit in kilometers per second
- `isLimited()`: returns if the limiter is activated
