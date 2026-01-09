--[[
Notes:
- hardcoded, manually-updated list of project files and folders
- unfortunately needed for both fetching and executing of all project files:
  - fetching: OpenOS has no package manager, so all files must be fetched
              individually using wget.
  - exec: Lua can't have recursive, arbitrary paths for module imports, so
          the exec script needs to know the folder structure to do it manually.
]]

local project = {}


project.folders = {
  "lib",
  "lib/common",
  "lib/robot",
  "lib/computer",
  "config",
  "crop_bot"
}

project.files = {
  "README.md",
  "exec.lua",
  "fetch.lua",
  "project.lua",
  "lib/common/binary_min_heap.lua",
  "lib/robot/patrol.lua",
  "lib/robot/move.lua",
  "crop_bot/README.md",
  "crop_bot/cultivate.lua"
}


return project

