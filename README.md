# gtnh_opencomputers
Scripts and libraries for my various GTNH OpenComputers systems.

Disclaimer: I'm completely new to Lua and still learning the ecosystem and best practices.  Additionally, OpenOS is very limited in features, has divergent or outright missing functionality from base Lua, comes with a lot of unique constraints (ie: no git, only wget), and has sparse documentation and online discussion.  I'm sure there are much better ways to structure this project, but I'm doing the best with what I got.  Please consider this a learning exercise and withhold judgment accordingly.

## Structure
- `root`: things with projectwide scope, such as downloading and executing project files.
- `lib`: module code for common libraries and ones specific to each OpenComputers entity.
- `config`: any kind of constants, environment vars, etc.
- `crop_bot`: code for running a robot that stat-maxes, propagates, and crossbreeds IC2 crops.

## Bootstrapping
OpenComputers entities run a very rudimentary, custom OS called OpenOS.  I haven't investigated whether it's even capable of running git natively, so until I invest time into that the best way to load this code is via `wget`.
1. Preinstall OpenOS on the robot's hard drive via a preexisting OpenComputers computer.  This saves the complexity point cost of installing a disk drive in the bot.
2. Build the robot in an OC electronics assembler using the parts described in this readme.
3. download both of the following scripts:
    - `wget https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/fetch.lua`
    - `wget https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/project.lua`
4. run `lua fetch.lua` from the directory you intend as your project root.  This WILL overwrite any preexisting files with matching names, so be careful if you have local changes.

## Executing Scripts
OpenOS doesn't appear to use the `LUA_PATH` variable to prepopulate its search path.  As such, `exec.lua` serves as the universal project entrypoint and will:
- prepend all of this project's directories to `package.path` so that module loading is seamless.
- (TODO) load configs and environment variables.
- (TODO) remove all project modules from the cache for QoL.  OpenOS preserves module loads indefinitely until you manually reboot the machine, so debugging can get very annoying very quickly.  

## Development
Guidelines for updating this project:
- add new files and folders to `project.lua`, or they won't get fetched by the fetcher script.

