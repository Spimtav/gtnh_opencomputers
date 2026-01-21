--[[
Notes:
- Common methods and state for crop bot scripts.
- Starting Inventory Assumptions:
  - Equipped: IC2 spade tool
  - Slot 1: Thaumic Tinkerer transvector binder
  - Slot 2: 64x IC2 crop sticks
- Assumptions:
  - parents are odd-summed coords, children are even
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


-------------------------------- Position --------------------------------------

function Crop_Bot:pos_str()
  return tostring(self.patrol.pos_curr)
end

function Crop_Bot:odd_pos()
  local x = self.patrol.pos_curr.x
  local y = self.patrol.pos_curr.y

  return ((x+y) % 2) == 1
end

function Crop_Bot:num_odds()
  local area = const.crop_bot.PLOT_LENGTH * const.crop_bot.PLOT_WIDTH

  return math.floor(area / 2)
end

------------------------------- Inventory --------------------------------------

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

function Crop_Bot:eject_all_misc()
  for i=1,const.crop_bot.INV_SIZE do
    if self.inv[i] == nil then
      bot.select(i)
      bot.drop(const.STACK_MAX)
    end
  end

  logging.print("Ejected inventory", const.log_levels.DEBUG)
end

---------------------------- Planting Checks -----------------------------------

function Crop_Bot:is_weed(scan_data)
  return scan_data[const.crop_bot.PLANT_NAME] == const.crop_bot.PLANT_NAME_WEED
end

function Crop_Bot:is_air(scan_data)
  return scan_data[const.crop_bot.BLOCK_NAME] == const.crop_bot.BLOCK_NAME_AIR
end

function Crop_Bot:is_crop(scan_data)
  return scan_data[const.crop_bot.BLOCK_NAME] == const.crop_bot.BLOCK_NAME_CROP
end

function Crop_Bot:is_empty_crop(scan_data)
  local crop = self:is_crop(scan_data)
  local is_empty = scan_data[const.crop_bot.PLANT_NAME] == const.crop_bot.PLANT_NAME_EMPTY

  return crop and is_empty
end

function Crop_Bot:is_plant(scan_data)
  local crop = self:is_crop(scan_data)
  local empty = self:is_empty_crop(scan_data)
  local weed = self:is_weed(scan_data)

  return crop and (not empty) and (not weed)
end

function Crop_Bot:is_mature(scan_data)
  local size_curr = scan_data[const.crop_bot.PLANT_SIZE]
  local size_max = scan_data[const.crop_bot.PLANT_SIZE_MAX]

  return size_curr == size_max
end

function Crop_Bot:same_species(scan_data, species)
  local name = scan_data[const.crop_bot.PLANT_NAME]

  return name == species
end

function Crop_Bot:analyze_crop()
  return geo.analyze(const.FACINGS[const.D])
end

------------------------------ Plant Stats -------------------------------------

function Crop_Bot:plant_stats(plant_data)
  local growth = plant_data[const.crop_bot.PLANT_GROWTH]
  local gain = plant_data[const.crop_bot.PLANT_GAIN]
  local resist = plant_data[const.crop_bot.PLANT_RESIST]

  return growth, gain, resist
end

function Crop_Bot:stat_diff(data_child, data_parent, stat_str)
  local stat_child = data_child[stat_str]
  local stat_parent = data_parent[stat_str]

  return stat_child - stat_parent
end

------------------------------ Serializers -------------------------------------

function Crop_Bot:stat_str(scan_data)
  if scan_data == nil then
    return "-"
  end

  if self:is_air(scan_data) then
    return "air"
  elseif self:is_weed(scan_data) then
    return "weed"
  elseif self:is_empty_crop(scan_data) then
    return "crop"
  end

  local name = scan_data[const.crop_bot.PLANT_NAME]
  local growth, gain, resist = self:plant_stats(scan_data)

  return name..","..tostring(growth)..","..tostring(gain)..","..tostring(resist)
end

function Crop_Bot:full_data_str(pos, scan_data)
  local str_pos = tostring(pos)
  local str_stats = self:stat_str(scan_data)

  return str_pos..":"..str_stats
end

---------------------------- Planting Actions ----------------------------------

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

function Crop_Bot:handle_air()
  self:add_crop()

  if not self:odd_pos() then
    self:add_crop()
  end
end

function Crop_Bot:bind_plant()
  self:equip(const.crop_bot.ITEM_BINDER)

  -- Sneaking needed bc harvesting takes normal right-click priority over binding
  bot.use(const.FACINGS[const.D], true)

  logging.print("Bound plant at: "..self:pos_str(), const.log_levels.DEBUG)
end

function Crop_Bot:clean_bind_dislocator()
  self.patrol:travel_pos(const.crop_bot.LOC_CROPS.POS, true)
  move.face_dir(const.crop_bot.LOC_CROPS.DIR)

  self:equip(const.crop_bot.ITEM_BINDER)
  bot.use(sides.front, true)
  bot.use(sides.front, true)
  logging.print("Unbound the dislocator", const.log_levels.DEBUG)

  self.patrol:travel_pos(const.crop_bot.LOC_DISLOCATOR.POS, true)
  move.face_dir(const.crop_bot.LOC_DISLOCATOR.DIR)
  bot.use(sides.front)
  logging.print("Bound dislocator", const.log_levels.DEBUG)

  self.patrol:travel_prev()
end

function Crop_Bot:swap_plant(binding_needed)
  if binding_needed then
    self:bind_plant()
  end

  self.patrol:travel_pos(const.crop_bot.LOC_DISLOCATOR.POS, true)
  move.face_dir(const.crop_bot.LOC_DISLOCATOR.DIR)

  redstone.setOutput(sides.front, 1)
  redstone.setOutput(sides.front, 0)

  self:equip(const.crop_bot.ITEM_BINDER)
  bot.use(sides.front)

  logging.print("Swapped plant at: "..self:pos_str(), const.log_levels.DEBUG)
end

function Crop_Bot:replace_plants(pos_child, pos_parent, data_child, data_parent)
  self.patrol:travel_pos(pos_child, true)
  self:swap_plant(true)
  self.patrol:travel_pos(pos_child, true)
  self:add_crop()
  self:add_crop()

  self.patrol:travel_pos(pos_parent, true)
  self:bind_plant()
  self:pluck_plant(false)
  self:swap_plant(false)

  local str_parent = self:full_data_str(pos_parent, data_parent)
  local str_child = self:full_data_str(pos_child, data_child)
  logging.print("Replaced parent ("..str_parent..") with child ("..str_child..")", const.log_levels.INFO)
end

function Crop_Bot:pluck_plant(replace_crops)
  self:equip(const.crop_bot.ITEM_SPADE)

  local scan_data = self:analyze_crop()

  if not self:is_mature(scan_data) then
    bot.useDown()
  end

  bot.swingDown()

  if replace_crops then
    self:handle_air()
  end
end

function Crop_Bot:pluck_child(pos_child, data_child, fail_reason)
  self.patrol:travel_pos(pos_child, true)

  self:pluck_plant(true)

  local str_child = self:full_data_str(pos_child, data_child)
  logging.print("Plucked child ("..str_child.."): "..fail_reason, const.log_levels.DEBUG)
end

function Crop_Bot:clear_plot()
  self:pluck_plant(false)

  logging.print("Cleared plot at: "..self:pos_str(), const.log_levels.DEBUG)
end


return Crop_Bot

