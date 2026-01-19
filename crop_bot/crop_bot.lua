--[[
Notes:
- Common methods and state for crop bot scripts.
- Starting Inventory Assumptions:
  - Equipped: IC2 spade tool
  - Slot 1: Thaumic Tinkerer transvector binder
  - Slot 2: 64x IC2 crop sticks
- Assumptions:
  - the Transvector Dislocator is pointed towards the swap plot
  - there are enough Advanced Item Collectors around the plot to automatically
    suck up and deposit items into your AE2 system / other storage
]]


local bot = require("robot")
local sides = require("sides")
local inv = require("component").inventory_controller
local geo = require("component").geolyzer
local redstone = require("component").redstone

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

function Crop_Bot:drop_all_misc()
  for i=1,const.crop_bot.INV_SIZE do
    if self.inv[i] == nil then
      bot.select(i)
      bot.drop(const.STACK_MAX)
    end
  end
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

function Crop_Bot:is_mature(crop_data)
  local size_curr = crop_data[const.crop_bot.PLANT_SIZE]
  local size_max = crop_data[const.crop_bot.PLANT_SIZE_MAX]

  return size_curr == size_max
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

  self.patrol:travel_pos(const.crop_bot.LOC_CROPS.POS, true)
  move.face_dir(const.crop_bot.LOC_CROPS.DIR)

  local crop_slot = self.items[const.crop_bot.ITEM_CROP]
  inv.suckFromSlot(sides.front, crop_slot, const.STACK_MAX - crop_size)
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

function Crop_Bot:clean_bind_dislocator()
  self:equip(const.crop_bot.ITEM_BINDER)
  bot.useDown()
  bot.useDown()
  logging.print("Unbound the dislocator", const.log_levels.DEBUG)

  self.patrol:travel_pos(const.crop_bot.LOC_DISLOCATOR.POS, true)
  move.face_dir(const.crop_bot.LOC_DISLOCATOR.DIR)
  bot.use(sides.front)
  logging.print("Bound dislocator", const.log_levels.DEBUG)

  self.patrol:travel_prev()
end

function Crop_Bot:bind_plant()
  self:equip(const.crop_bot.ITEM_BINDER)
  bot.useDown()

  logging.print("Bound plant at: "..self:pos_str(), const.log_levels.DEBUG)
end

function Crop_Bot:swap_plant()
  self:bind_plant()
  self.patrol:travel_pos(const.crop_bot.LOC_DISLOCATOR.POS, true)
  move.face_dir(const.crop_bot.LOC_DISLOCATOR.DIR)

  redstone.setOutput(sides.front, 1)
  redstone.setOutput(sides.front, 0)

  self:equip(const.crop_bot.ITEM_BINDER)
  bot.use(sides.front)

  logging.print("Swapped plant at: "..self:pos_str(), const.log_levels.DEBUG)
end

function Crop_Bot:replace_plants(pos_child, pos_parent)
  local pos_original = coord:new(self.patrol.pos_curr.x, self.patrol.pos_curr.y)

  self.patrol:travel_pos(pos_child, true)
  self:swap_plant()
  self.patrol:travel_pos(pos_child, true)
  self:add_crop()
  self:add_crop()

  self.patrol:travel_pos(pos_parent, true)
  self:equip(const.crop_bot.ITEM_SPADE)
  bot.swingDown()

  self:swap_plant()

  logging.print("Replaced parent ("..tostring(pos_parent)..") with child ("..tostring(pos_child)..")", const.log_levels.DEBUG)
end

function Crop_Bot:pluck_child()
  self:equip(const.crop_bot.ITEM_SPADE)

  local data_child = self:analyze_crop()
  if self:is_mature(data_child) then
    bot.swingDown()
    self:add_crop()
    self:add_crop()
  else
    bot.useDown()
    self:add_crop()
  end

  logging.print("Plucked child at: "..self:pos_str(), const.log_levels.DEBUG)
end


return Crop_Bot

