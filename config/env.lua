--[[
Notes:
- for more transient project configuration
- loaded after consts and common modules  but before [module].main()
]]


local env = {}


env.log_level = const.log_levels.INFO


return env

