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
  PLOT_LENGTH = 2,
  PLOT_WIDTH = 2,

  INV_SIZE = 16,
  MIN_CROPS = 1,

  LOC_CROPS = {
    POS = coord:new(0,0),
    DIR = const.W
  },
  LOC_DISLOCATOR = {
    POS = coord:new(0,1),
    DIR = const.W
  },
  LOC_SWAP = {
    POS = coord:new(0,2),
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

  PLANT_NAME_WEED = "weed",
  PLANT_NAME_EMPTY = nil,
  BLOCK_NAME_CROP = "IC2:blockCrop",
  BLOCK_NAME_AIR = "minecraft:air"
}

const.crop_bot.cultivate = {
  MAX_GROWTH = 21,
  MAX_GAIN = 31
}


return const

