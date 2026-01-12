--[[
Notes:
- plot assumptions:
  - plot is made up of soil that can accept IC2 crop sticks
  - plot is one tile below the robot
  - plot is small enough that robot won't run out of energy during operation
- crop assumptions:
  - initial crops to optimize are placed at odd coords
  - all odd coords are pre-planted with identical crop-types to stat-up
  - no pre-planted crops have any stat that's greater than the desired stats
- robot assumptions:
  - robot has an equipped Crops++ spade (which is unbreakable)
  - robot has a Thaumic Tinkerer transvector binder in its inventory
- block assumptions:
  - charger is 1 block left of bottom left corner of plot
  - IC2 crop stick storage container:
    - 1 block down of bottom left corner of plot
    - infinitely restocked with crop sticks via another system
    - never depletes
]]


bot = require("robot")
geo = require("component").geolyzer
move = require("move")
patrol = require("patrol")


local Cultivate = {}


function Cultivate:new()
  local new_cul = {
    crops_parent = {},
    crops_child = {},
    patrol = patrol:new()
  }
  setmetatable(new_cul, self)
  self.__index = self
  return new_cul
end

function Cultivate:pos_str()
  local pos_curr = self.patrol.pos_curr

  return pos_curr.x..","..pos_curr.y
end

function Cultivate:crop_stat_str(stat_table)
  if stat_table == nil then
    return "-"
  end

  local name = stat_table["crop:name"]
  local growth = stat_table["crop:growth"]
  local gain = stat_table["crop:gain"]
  local resistance = stat_table["crop:resistance"]

  return name..": "..growth..","..gain..","..resistance
end

function Cultivate:odd_pos()
  local x = self.patrol.pos_curr.x
  local y = self.patrol.pos_curr.y

  return (x+y % 2) == 1
end

function Cultivate:print_crop_table(table)
  for k,v in pairs(table) do
    logging.print(k..": ["..self.crop_stat_str(v).."]", const.log_levels.DEBUG)
  end
end

function Cultivate:is_weed(crop_data)
  return crop_data["crop:name"] == "weed"
end

function Cultivate:is_empty(crop_data)
  return crop_data["crop:name"] == nil
end

function Cultivate:analyze_crop()
  local crop_data = geo.analyze(move.FACINGS["D"])

  local crops_table = self.crops_child
  if self:odd_pos() then
    crops_table = self.crops_parent
  end

  if self:is_weed(crop_data) or self:is_empty(crop_data) then
    return
  end

  crops_table[pos_str()] = crop_data
end

function Cultivate:cultivate()
  local length = const.crop_bot.cultivate.PLOT_LENGTH
  local width = const.crop_bot.cultivate.PLOT_WIDTH
  self.patrol:patrol(self:analyze_crop, length, width)

  print("Parents (odd):")
  print_crop_table(PARENT_CROPS)
  print("\n\n")
  print("Children (even):"
  print_crop_table(CHILD_CROPS)
end


function main()
  local cul = Cultivate:new()

  cul:cultivate()
end


return Cultivate

