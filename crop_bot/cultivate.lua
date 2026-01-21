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


coord = require("coord")
crop_bot = require("crop_bot")



local Cultivate = {}


function Cultivate:new()
  local new_cul = {
    crop_bot = crop_bot:new(),

    data_parents = {},
    data_childs = {},
    min_growth = 99,
    min_gain = 99,
    max_resist = -99,
    num_parents = 0,
    num_maxed_parents = 0,
    num_loops = 0
  }
  new_cul["num_parents"] = new_cul["crop_bot"]:num_odds()
  setmetatable(new_cul, self)
  self.__index = self
  return new_cul
end

function Cultivate:print_data_table(data_table)
  for pos_str, scan_data in pairs(data_table) do
    logging.print(self.crop_bot:full_data_str(pos_str, scan_data), const.log_levels.DEBUG)
  end
end

-------------------------------- Crop Stats ------------------------------------

function Cultivate:invalid_reason_str(min_stat, invalid_stat, max_stat)
  local str_min = tostring(min_stat)
  local str_invalid = tostring(invalid_stat)
  local str_max = tostring(max_stat)

  return "["..str_min..",("..str_invalid.."),"..str_max.."]"
end

function Cultivate:valid_child(data_child)
  if not self.crop_bot:is_plant(data_child) then
    return false, "not a plant"
  elseif not self.crop_bot:same_species(data_child, const.crop_bot.cultivate.SPECIES) then
    return false, "wrong species"
  end

  local growth, gain, resist = self.crop_bot:plant_stats(data_child)

  local max_growth = const.crop_bot.cultivate.MAX_GROWTH
  local max_gain = const.crop_bot.cultivate.MAX_GAIN
  local max_resist = const.crop_bot.cultivate.MAX_RESIST

  local valid_growth = (growth <= max_growth) and (growth >= self.min_growth)
  if not valid_growth then
    return false, "invalid growth "..self:invalid_reason_str(self.min_growth, growth, max_growth)
  end

  local valid_gain = (gain <= max_gain) and (gain >= self.min_gain)
  if not valid_gain then
    return false, "invalid gain "..self:invalid_reason_str(self.min_gain, gain, max_gain)
  end

  local valid_resist = resist <= self.max_resist
  if not valid_resist then
    return false, "invalid resist "..self:invalid_reason_str(self.max_resist, resist, max_resist)
  end

  return true, nil
end

function Cultivate:total_stat_improvement(data_child, data_parent)
  local diff_growth = self.crop_bot:stat_diff(data_child, data_parent, const.crop_bot.PLANT_GROWTH)
  local diff_gain = self.crop_bot:stat_diff(data_child, data_parent, const.crop_bot.PLANT_GAIN)

  return diff_growth + diff_gain
end

function Cultivate:child_regression(data_child, data_parent)
  local growth_child, gain_child, resist_child = self.crop_bot:plant_stats(data_child)
  local growth_parent, gain_parent, resist_parent = self.crop_bot:plant_stats(data_parent)

  local lower_growth = growth_child < growth_parent
  local lower_gain = gain_child < gain_parent
  local higher_resist = resist_child > resist_parent

  return lower_growth or lower_gain or higher_resist
end

-- Assumes child is already validated
function Cultivate:lowest_parent(data_child)
  local lowest_parent_key = nil
  local highest_progress = 0
  local num_regressions = 0

  for pos_str_parent, data_parent in pairs(self.data_parents) do
    local regressed = self:child_regression(data_child, data_parent)
    local progress = self:total_stat_improvement(data_child, data_parent)

    if regressed then
      num_regressions = num_regressions + 1
    end

    if (not regressed) and (progress > highest_progress) then
      lowest_parent_key = pos_str_parent
      highest_progress = progress
    end
  end

  local fail_reason = nil
  if num_regressions == self.num_parents then
    fail_reason = "regression"
  elseif lowest_parent_key == nil then
    fail_reason = "no improvement"
  end

  return lowest_parent_key, fail_reason
end

function Cultivate:plant_maxed(data)
  local growth, gain, resist = self.crop_bot:plant_stats(data)

  local max_growth = const.crop_bot.cultivate.MAX_GROWTH
  local max_gain = const.crop_bot.cultivate.MAX_GAIN
  local max_resist = const.crop_bot.cultivate.MAX_RESIST

  return (growth == max_growth) and (gain == max_gain) and (resist == max_resist)
end

function Cultivate:parents_maxed()
  if self.num_loops == 0 then
    return false
  end

  return self.num_maxed_parents == self.num_parents
end

----------------------------------- Cultivation --------------------------------

function Cultivate:handle_patrol()
  local scan_data = self.crop_bot:analyze_crop()
  local updated_plot = false

  if self.crop_bot:is_air(scan_data) then
    self.crop_bot:handle_air()
    updated_plot = true
  end

  if self.crop_bot:is_weed(scan_data) then
    self.crop_bot:handle_weed()
    updated_plot = true
  end

  if updated_plot then
    scan_data = self.crop_bot:analyze_crop()
  end

  local crop_pos = self.crop_bot:pos_str()
  if self.crop_bot:odd_pos() then
    self.data_parents[crop_pos] = scan_data
  else
    self.data_childs[crop_pos] = scan_data
  end
end

function Cultivate:handle_parent_stats()
  local num_maxed = 0

  for _, data_parent in pairs(self.data_parents) do
    local growth, gain, resist = self.crop_bot:plant_stats(data_parent)

    self.min_growth = math.min(growth, self.min_growth)
    self.min_gain = math.min(gain, self.min_gain)
    self.max_resist = math.max(resist, self.max_resist)

    if self:plant_maxed(data_parent) then
      num_maxed = num_maxed + 1
    end
  end

  self.num_maxed_parents = num_maxed

  local stat_str = tostring(self.min_growth)..","..tostring(self.min_gain)..","..tostring(self.max_resist)
  local maxed_str = tostring(self.num_maxed_parents).."/"..tostring(self.num_parents)
  logging.print("Parent floors: "..stat_str.. "("..maxed_str..")", const.log_levels.INFO)
end

function Cultivate:handle_replacement(pos_child, data_child)
  local pos_str_lowest_parent, fail_reason = self:lowest_parent(data_child)

  if pos_str_lowest_parent == nil then
    self.crop_bot:pluck_child(pos_child, fail_reason)
  else
    local pos_lowest_parent = coord:new_from_str(pos_str_lowest_parent)
    self.crop_bot:replace_plants(pos_child, pos_lowest_parent, data_child, data_lowest_parent)
    self.data_parents[pos_str_lowest_parent] = data_child
  end
end

function Cultivate:handle_cleanup()
  if not self.crop_bot:odd_pos() then
    self.crop_bot:clear_plot()
  end
end

function Cultivate:cultivate()
  local length = const.crop_bot.PLOT_LENGTH
  local width = const.crop_bot.PLOT_WIDTH

  self.crop_bot:clean_bind_dislocator()

  while not self:parents_maxed() do
    self.num_loops = self.num_loops + 1

    logging.print("Loop "..tostring(self.num_loops), const.log_levels.INFO)

    self.crop_bot.patrol:patrol(self.handle_patrol, self, length, width)
    self:handle_parent_stats()

    for pos_str_child, data_child in pairs(self.data_childs) do
      local pos_child = coord:new_from_str(pos_str_child)
      local valid, fail_reason = self:valid_child(data_child)

      if not self.crop_bot:is_plant(data_child) then
        logging.print("Ignoring empty child at: "..pos_str_child, const.log_levels.DEBUG)
      elseif not valid then
        self.crop_bot:pluck_child(pos_child, fail_reason)
      else
        self:handle_replacement(pos_child, data_child)
      end
    end

    logging.print("\n"..string.rep("_", 30), const.log_levels.INFO)
  end

  self.crop_bot.patrol:patrol(self.handle_cleanup, self, length, width)
  self.crop_bot:eject_all_misc()
end


function Cultivate.main()
  local cul = Cultivate:new()

  cul:cultivate()

  logging.print("Finished cultivating", const.log_levels.DEBUG)
end


return Cultivate

