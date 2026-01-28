--[[
Notes:
- for global constants and classes/definitions
- loaded in exec before running scripts, so modules can reference consts
]]


local coord = require("coord")

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

const.STACK_MAX = 64

const.N = "N"
const.S = "S"
const.W = "W"
const.E = "E"
const.D = "D"
const.U = "U"

const.FACINGS = {
  [const.D] = 0,
  [const.U] = 1,
  [const.N] = 2,
  [const.S] = 3,
  [const.W] = 4,
  [const.E] = 5
}

const.MC_FACINGS = {
  [0] = const.D,
  [1] = const.U,
  [2] = const.N,
  [3] = const.S,
  [4] = const.W,
  [5] = const.E
}

const.crop_bot = {

  GROWTH_THRESH_WEED = 24
  PLOT_LENGTH = 7,
  PLOT_WIDTH = 7,

  INV_SIZE = 16,
  MIN_CROPS = 4,
  CROP_CHEST_SLOT = 2,

  RECHARGE_TIMEOUT = 5,

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
  },

  ITEM_EQUIPPED = "equipped",
  ITEM_SPADE = "berriespp:itemSpade",
  ITEM_BINDER = "ThaumicTinkerer:connector",
  ITEM_CROP = "IC2:blockCrop",
  ITEM_WEED = "IC2:itemWeed",
  ITEM_SEED = "IC2:itemCropSeed",

  PLANT_NAME = "crop:name",
  PLANT_GROWTH = "crop:growth",
  PLANT_GAIN = "crop:gain",
  PLANT_RESIST = "crop:resistance",
  PLANT_SIZE = "crop:size",
  PLANT_SIZE_MAX = "crop:maxSize",
  BLOCK_NAME = "name",

  BLOCK_NAME_CROP = "IC2:blockCrop",
  BLOCK_NAME_AIR = "minecraft:air",

  PLANT_NAMES = {
    EMPTY = nil,
    WEED = "weed",

    STICKREED = "stickreed",
    GLOWSHROOM = "Glowshroom",
    SALTY_ROOT = "saltroot"
  }
}

const.crop_bot.cultivate = {
  MAX_GROWTH = 20,
  MAX_GAIN = 31,
  MAX_RESIST = 0,
  SPECIES = "stickreed",

  DATA = {
    SWAPS = "Sw",
    CROSSES = "Cr",

    PLUCKS = "Pl",
    INVALID_STATS = "InS",
    NO_PROGRESSES = "NoP",
    WEEDS = "We",
    WEEDY_GROWTHS = "WeG"
  }
}

const.crop_bot.propagate = {
  MODE_SEEDS = "mode_seeds",
  MODE_FIELD = "mode_field",

  DATA = {
    TARGETS = "Ta=",
    BETTERS = "Ta+",

    CROSSES = "Cr",
    PLUCKS = "Pl",
    INVALID_STATS = "InS",
    WEEDS = "We",
    WEEDY_GROWTHS = "WeG"
  }
}


return const

