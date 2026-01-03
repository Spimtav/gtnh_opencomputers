# IC2 Crops Robot (Croppy)
This dir contains various scripts for automating a robot to perform various procedures on IC2 crops:
- setup.lua: fetches all of the crop_bot code and common robot libraries to the current dir.
  - WARNING: overwrites any existing files.
- .shrc: gets run on boot, mostly used for convenience stuff.
- test.lua: convenience script to make testing and debugging easier.
- cultivate.lua: script for robot to create a plot of IC2 crops with the specified stats
  - odd coords: crops with specified stats
  - even coords: empty w/o crop sticks (to prevent weeds)

## Bootstrapping
OpenComputers computers run a very rudimentary, custom OS called OpenOS.  I haven't investigated whether it's even capable of running git natively, so until I invest time into that the best way to load this code is via `wget`.
1. Preinstall OpenOs on the robot's hard drive via a preexisting OpenComputers computer.  This saves the complexity cost of installing a disk drive in the bot.
2. Build the robot in an OC electronics assembler using the parts described in this readme.
2. download the setup stript: `wget https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/crop_bot/setup.lua`
3. run `./setup.lua`.  This stript WILL overwrite any existing files, so be careful if you have local changes.

## Bot Config
- base:
    - Tier 3 computer case
    - Tier (TBD) memory
    - Tier 2 accelerated procesing unit
    - Tier (TBD) hard disk drive (with OpenOs preinstalled)
    - Tier 1 screen
    - EEPROM (Lua BIOS)
- functionality:
    - keyboard
    - geolyzer
- containers:
    - Tier (TBD) card container
    - Tier (TBD) upgrade container
- cards:
    - Tier 1 redstone card
    - internet card
    - sound card
    - particle effects card (via card container)
- upgrades:
    - inventory controller upgrade
    - 1x inventory upgrade
    - chat upgrade
    - colorful upgrade
    - navigation upgrade (via upgrade container)
