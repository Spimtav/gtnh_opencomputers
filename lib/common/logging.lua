--[[
Notes:
- wrapper of Lua print that obeys log levels
]]


local logging = {}


local logging.print(s, level)
  if level >= env.log_level then
    print(const.log_level_names[level]..": "..s)
  end
end


return logging

