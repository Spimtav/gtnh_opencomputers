--[[
Notes:
- for global constants and classes/definitions
- loaded in exec before running scripts, so modules can reference consts
]]


local const = {}


const.log_levels = {
  DEBUG = 0,
  INFO = 1,
  WARNING = 2,
  ERROR = 3,
  CRITICAL = 4
}
const.log_level_names = {}
for k,v in pairs(const.log_levels) do
  const.log_level_names[v] = k
end


return const

