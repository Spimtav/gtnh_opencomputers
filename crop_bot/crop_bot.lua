--[[
Notes:
- Common methods and state for crop bot scripts.
- Starting Inventory Assumptions:
  - Equipped: IC2 spade tool
  - Slot 1: Thaumic Tinkerer transvector binder
  - Slot 2: 64x IC2 crop sticks
]]


local bot = require("robot")
local inv = require("component").inventory_controller
local geo = require("component").geolyzer
local sides = require("sides")
local move = require("move")
local patrol = require("patrol")


local Crop_Bot = {}


function Crop_Bot:new()
  local new_bot = {
    patrol = patrol:new(),
    item_equipped = const.crop_bot.ITEM_SPADE,
    inv = {
      [1] = const.crop_bot.ITEM_BINDER,
      [2] = const.crop_bot.ITEM_CROP
    },
    items = {
      [const.crop_bot.ITEM_SPADE] = const.crop_bot.ITEM_EQUIPPED,
      [const.crop_bot.ITEM_BINDER] = 1,
      [const.crop_bot.ITEM_CROP] = 2
    }
  }
  setmetatable(new_bot, self)
  self.__index = self
  return new_bot
end


-- Position
function Crop_Bot:pos_str()
  return tostring(self.patrol.pos_curr)
end

function Crop_Bot:odd_pos()
  local x = self.patrol.pos_curr.x
  local y = self.patrol.pos_curr.y

  return (x+y % 2) == 1
end

-- Inventory
function Crop_Bot:equip(item)
  local item_slot = self.items[item]
  if item_slot == const.crop_bot.ITEM_EQUIPPED then
    return
  end

  bot.select(item_slot)
  inv.equip()

  local swapped_item = self.item_equipped
  self.item_equipped = item
  self.inv[item_slot] = swapped_item
  self.items[item] = const.crop_bot.ITEM_EQUIPPED
  self.items[swapped_item] = item_slot
end

-- Planting Checks
function Crop_Bot:crop_stat_str(stat_table)
  if stat_table == nil then
    return "-"
  end

  local name = stat_table["crop:name"]
  local growth = stat_table["crop:growth"]
  local gain = stat_table["crop:gain"]
  local resistance = stat_table["crop:resistance"]

  return name..": "..growth..","..gain..","..resistance
end

function Crop_Bot:is_weed(crop_data)
  return crop_data[const.crop_bot.PLANT_NAME] == const.crop_bot.PLANT_WEED
end

function Crop_Bot:is_empty(crop_data)
  return crop_data[const.crop_bot.PLANT_NAME] == const.crop_bot.PLANT_AIR
end

function Crop_Bot:analyze_crop()
  return geo.analyze(const.FACINGS[const.D])
end

-- Planting Actions
function Crop_Bot:replenish_crops()
  self:equip(const.crop_bot.ITEM_SPADE)

  local crops = inv.getStackInInternalSlot(self.items[const.crop_bot.ITEM_CROP])
  local crop_size = crops.size
  if crops.size > const.crop_bot.MIN_CROPS then
    return
  end

  self.patrol:travel_pos(const.crop_bot.LOC_CROPS.COORD)
  move.face_dir(const.crop_bot.LOC_CROPS.DIR)

  local crop_slot = self.items[const.crop_bot.ITEM_CROP]
  inv.suckFromSlot(sides.front, crop_slot, 64 - crop_size)
  logging.print("Replenished crops", const.log_levels.DEBUG)

  self.patrol:travel_prev()
end

function Crop_Bot:add_crop()
  self:replenish_crops()

  self:equip(const.crop_bot.ITEM_CROP)
  bot.useDown()

  logging.print("Used crop stick at: "..self:pos_str(), const.log_levels.DEBUG)
end

-- TODO: replace weedified parent plant
function Crop_Bot:handle_weed()
  self:equip(const.crop_bot.ITEM_SPADE)
  bot.useDown()
  logging.print("Removed weed at: "..self:pos_str(), const.log_levels.DEBUG)

  if not self:odd_pos() then
    self:add_crop()
  end
end


return Crop_Bot

