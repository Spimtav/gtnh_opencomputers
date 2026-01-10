--[[
Notes:
- universal entry point for all project scripts
  - assumes project scripts have a main() method as their entry point
- (TODO) loads common configs, constants, and env vars for scripts to use
- (TODO) drops project modules from the cache to make life easier
]]


local fs = require("filesystem")
local shell = require("shell")
local paths_env_var = "PATHS_LOADED"
local args = {...}


if args[1] == nil then
  print("Usage: `lua [path/]exec.lua <project-script-name>`")
  return 1
end

local script_path = debug.getinfo(2).source:sub(2):match("(.*)/") or "."
local abs_root = shell.resolve(script_path)
local project = dofile(abs_root.."/project.lua")

-- Set project paths if not set

if os.getenv(paths_env_var) == nil then
  os.setenv(paths_env_var, ";")
end
local paths_loaded = os.getenv(paths_env_var)

if not string.find(paths_loaded, ";"..abs_root..";", 1, true) then
  for _,subdir in pairs(project.folders) do
    package.path = abs_root.."/"..subdir.."/?.lua;"..package.path
  end
  package.path = abs_root.."/?.lua;"..package.path

  os.setenv(paths_env_var, paths_loaded..abs_root..";")
end

-- Clear cached project modules
for _,filepath in pairs(project.files) do
  local file_name = fs.name(filepath)
  if file_name:match(".*%.lua$") ~= nil then
    file_name = file_name:sub(1, #file_name - 4)
    package.loaded[file_name] = nil
  end
end

-- Execute specified script's main()
local script_mod = require(args[1])

script_mod.main()

