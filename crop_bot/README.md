# IC2 Crops Robot (Croppy)
This dir contains various scripts for automating a robot to perform various procedures on IC2 crops:
- setup.lua: fetches all of the crop_bot code to the current dir.
  - WARNING: overwrites any existing files.
- .shrc: gets run on boot, mostly used for convenience stuff.
- test.lua: convenience script to make testing and debugging easier.

## Bootstrapping
OpenComputers computers run a very rudimentary, custom OS called OpenOS.  I haven't investigated whether it's even capable of running git natively, so until I invest time into that the best way to load this code is via `wget`.
1. insert OpenOS floppy into robot's disk drive and boot the robot.  Run `install` and follow the instructions.  The floppy is no longer needed.
2. download the setup stript: `wget https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/crop_bot/setup.lua`
3. run `./setup.lua`.  This stript WILL overwrite any existing files, so be careful if you have local changes.

## Bot Config
- base:
    - Tier 3 computer case
    - Tier (TBD) memory
    - Tier 2 accelerated procesing unit
    - Tier (TBD) hard disk drive
    - Tier 1 screen
    - EEPROM (Lua BIOS)
- functionality:
    - keyboard
    - geolyzer
    - disk drive block
- cards:
    - Tier 1 redstone card
    - internet card
    - sound card
    - particle effects card (via Tier (?) card container upgrade)
- upgrades:
    - inventory controller upgrade
    - (TBD)x inventory upgrade
    - chat upgrade
    - colorful upgrade

