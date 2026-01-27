--[[
Notes:
- for more transient project configuration
- loaded after consts and common modules  but before [module].main()
]]


local env = {}


env.log_level = const.log_levels.WARNING

env.propagate = {
  MODE = const.crop_bot.propagate.MODE_SEEDS,
  MAX_LOOPS_SEEDS = 500,

  PLOT_LENGTH = 7,
  PLOT_WIDTH = 7,

  SPECIES = "saltroot",
  MIN_GROWTH = 20,
  MIN_GAIN = 31,
  MAX_RESIST = 0
}


return env

