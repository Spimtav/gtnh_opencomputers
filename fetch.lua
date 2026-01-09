--[[
Notes:
- OpenOS only has wget, so we've gotta fetch all these individually and
  replicate the directory structure ourselves :(

WARNINGS:
- will overwrite files

]]


local shell = require("shell")
local fs = require("filesystem")
local base_url = "https://raw.githubusercontent.com/Spimtav/gtnh_opencomputers/refs/heads/main/"


local script_path = debug.getinfo(2).source:sub(2):match("(.*)/") or "."
local abs_root = shell.resolve(script_path)
local project = dofile(abs_root.."/project.lua")


-- replicate directory structure
for _,dir in pairs(project.folders) do
  fs.makeDirectory(abs_root.."/"..dir)
end

-- fetch files from github
for _, file in pairs(project.files) do
  local github_url = base_url..file
  os.execute("wget -f "..github_url.." "..file)
end

