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


crop_bot = require("crop_bot")


local Cultivate = {}


function Cultivate:new()
  local new_cul = {
    crops_parent = {},
    crops_child = {},
    crop_bot = crop_bot:new()
  }
  setmetatable(new_cul, self)
  self.__index = self
  return new_cul
end


function Cultivate:print_crop_table(table)
  for k,v in pairs(table) do
    logging.print(k..": ["..self.crop_bot:crop_stat_str(v).."]", const.log_levels.DEBUG)
  end
end

function Cultivate:cultivate()
  local crop_data = self.crop_bot:analyze_crop()

  if self.crop_bot:is_weed(crop_data) then
    self.crop_bot:handle_weed()
  end

  local crop_pos = self.crop_bot:pos_str()
  if self.crop_bot:odd_pos() then
    self.crops_parent[crop_pos] = crop_data
  else
    self.crops_child[crop_pos] = crop_data
  end
end


function Cultivate.main()
  local length = const.crop_bot.PLOT_LENGTH
  local width = const.crop_bot.PLOT_WIDTH
  local cul = Cultivate:new()

  for i=1,2 do
    cul.crop_bot.patrol:patrol(cul.cultivate, cul, length, width)

    logging.print("Parents (odd):", const.log_levels.DEBUG)
    cul:print_crop_table(cul.crops_parent)
    logging.print("Children (even):", const.log_levels.DEBUG)
    cul:print_crop_table(cul.crops_child)
  end

  logging.print("Finished cultivating", const.log_levels.DEBUG)
end


return Cultivate

