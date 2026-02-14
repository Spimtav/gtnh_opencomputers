--[[
Notes:
- for more transient project configuration
- loaded after consts and common modules  but before [module].main()
]]

local coord = require("coord")


local env = {}


env.log_level = const.log_levels.WARNING


env.patrol = {
  ENERGY_MIN = 15,   -- % of max
  ENERGY_SLEEP = 8,  -- sec
  LOOP_SLEEP = 5     -- sec
}

env.crop_bot = {
  GROWTH_THRESH_WEED = 24,

  INV_SIZE = 16,
  MIN_CROPS = 4,
  CROP_STORAGE_SLOT = 2,

  SLOT_BINDER = 1,
  SLOT_CROPS = 2,

  LOC_CROPS = {
    POS = coord:new(0,0),
    DIR = const.S
  },
  LOC_DISLOCATOR = {
    POS = coord:new(0,4),
    DIR = const.W
  },
  LOC_SWAP = {
    POS = coord:new(0,5),
    DIR = const.W
  }
}

env.cultivate = {
  PLOT_LENGTH = 7,
  PLOT_WIDTH = 7,

  SPECIES = const.crop_bot.PLANT_NAMES.GLOWFLOWER,
  MAX_GROWTH = 20,
  MAX_GAIN = 31,
  MAX_RESIST = 0
}

env.propagate = {
  MODE = const.crop_bot.propagate.MODE_SEEDS,
  MAX_LOOPS_SEEDS = 700,

  PLOT_LENGTH = 10,
  PLOT_WIDTH = 10,

  SPECIES = const.crop_bot.PLANT_NAMES.GLOWFLOWER,
  MIN_GROWTH = 20,
  MIN_GAIN = 31,
  MAX_RESIST = 0
}


return env

