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

term = require("term")

coord = require("coord")
crop_bot = require("crop_bot")



local Cultivate = {}


function Cultivate:new()
  local new_cul = {
    crop_bot = crop_bot:new(),

    data_parents = {},
    growth = {},
    gain = {},
    resist = {},

    num_loops = 0,
    num_parents = 0,
    num_maxed_parents = 0,
    num_prev_maxed_parents = 0,

    data = {},
    loop_deltas = {}
  }
  new_cul["num_parents"] = new_cul["crop_bot"]:num_odds()
  setmetatable(new_cul, self)
  self.__index = self
  return new_cul
end

------------------------------- Accumulated Data -------------------------------

function Cultivate:data_str(s)
  local data = self.data[s]
  local delta = self.loop_deltas[s]

  local data_str = tostring(data)..s

  if delta == 0 then
    return data_str
  end

  return data_str.."(+"..tostring(delta)..")"
end

function Cultivate:maxed_parents_str()
  local data_str = "Maxed Parents: "..tostring(self.num_maxed_parents).."/"..tostring(self.num_parents)
  local delta = self.num_maxed_parents - self.num_prev_maxed_parents

  local sign = ""
  if delta == 0 then
    return data_str
  elseif delta > 0 then
    sign = "+"
  end

  return data_str.." ("..sign..tostring(delta)..")"
end

function Cultivate:increment_data(data_key)
  local data_str = const.crop_bot.cultivate.DATA[data_key]

  self.data[data_str] = self.data[data_str] + 1
  self.loop_deltas[data_str] = self.loop_deltas[data_str] + 1
end

function Cultivate:new_data_table()
  local data_table = {}

  for _,v in pairs(const.crop_bot.cultivate.DATA) do
    data_table[v] = 0
  end

  return data_table
end

--------------------------------- Prints ---------------------------------------

function Cultivate:print_data_table(data_table)
  for pos_str, scan_data in pairs(data_table) do
    logging.print(self.crop_bot:full_data_str(pos_str, scan_data), const.log_levels.DEBUG)
  end
end

function Cultivate:sorted_keys(t)
  local new_t = {}
  for k,_ in pairs(t) do
    table.insert(new_t, k)
  end

  table.sort(new_t)
  return new_t
end

function Cultivate:print_data_screen()
  -- row data init
  local header_sep = string.rep(" ", 10)
  local stat_header = "Growth"

  stat_header = stat_header..header_sep
  local offset_gain = string.len(stat_header)
  stat_header = stat_header.."Gain"

  stat_header = stat_header..header_sep
  local offset_resist = string.len(stat_header)
  stat_header = stat_header.."Resistance"

  local sorted_growth = self:sorted_keys(self.growth)
  local sorted_gain = self:sorted_keys(self.gain)
  local sorted_resist = self:sorted_keys(self.resist)

  local num_rows = math.max(table.unpack({#sorted_growth, #sorted_gain, #sorted_resist}))

  -- other data init
  local maxed_parents_str = self:maxed_parents_str()

  local pluck_table = {
    self:data_str(const.crop_bot.cultivate.DATA.INVALIDS),
    self:data_str(const.crop_bot.cultivate.DATA.INVALID_STATS),
    self:data_str(const.crop_bot.cultivate.DATA.NO_PROGRESSES),
    self:data_str(const.crop_bot.cultivate.DATA.WEEDS),
    self:data_str(const.crop_bot.cultivate.DATA.WEEDY_GROWTHS)
  }
  local pluck_stats = "("..table.concat(pluck_table, "|")..")"

  -- screen updates
  term.clear()

  print("Loop: "..tostring(self.num_loops))
  print(string.rep("=", 30))
  print(maxed_parents_str)
  print("Swaps: "..self:data_str(const.crop_bot.cultivate.DATA.SWAPS))
  print("Crosses: "..self:data_str(const.crop_bot.cultivate.DATA.CROSSES))
  print("Plucks: "..self:data_str(const.crop_bot.cultivate.DATA.PLUCKS))

  print(stat_header)
  print(string.rep("_", 40))
  for i=1,num_rows do
    local str_growth, str_gain, str_resist = "", "", ""

    if i <= #sorted_growth then
      local val_growth = sorted_growth[i]
      local count_growth = self.growth[val_growth]
      str_growth = tostring(val_growth)..":"..tostring(count_growth)
    end
    if i <= #sorted_gain then
      local val_gain = sorted_gain[i]
      local count_gain = self.gain[val_gain]
      str_gain = tostring(val_gain)..":"..tostring(count_gain)
    end
    if i <= #sorted_resist then
      local val_resist = sorted_resist[i]
      local count_resist = self.resist[val_resist]
      str_resist = tostring(val_resist)..":"..tostring(count_resist)
    end

    local row = ""
    row = row..str_growth
    row = row..string.rep(" ", offset_gain - string.len(row))..str_gain
    row = row..string.rep(" ", offset_resist - string.len(row))..str_resist

    print(row)
  end
end

-------------------------------- Crop Stats ------------------------------------

function Cultivate:invalid_reason_str(min_stat, invalid_stat, max_stat)
  local str_min = tostring(min_stat)
  local str_invalid = tostring(invalid_stat)
  local str_max = tostring(max_stat)

  return "["..str_min..",("..str_invalid.."),"..str_max.."]"
end

function Cultivate:increment_stat_table(stat_table, stat)
  if stat_table[stat] == nil then
    stat_table[stat] = 0
  end

  stat_table[stat] = stat_table[stat] + 1
end

function Cultivate:decrement_stat_table(stat_table, stat)
  stat_table[stat] = stat_table[stat] - 1

  if stat_table[stat] == 0 then
    stat_table[stat] = nil
  end
end

function Cultivate:min_growth()
  local growths_asc = self:sorted_keys(self.growth)
  return growths_asc[1]
end

function Cultivate:min_gain()
  local gains_asc = self:sorted_keys(self.gain)
  return gains_asc[1]
end

function Cultivate:max_resist()
  local resists_asc = self:sorted_keys(self.resist)
  return resists_asc[#resists_asc]
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

---------------------------------- Plant Logic ---------------------------------

function Cultivate:valid_growth(growth)
  local max_growth = const.crop_bot.cultivate.MAX_GROWTH
  local min_growth = self:min_growth()

  if (growth > max_growth) or (growth < min_growth) then
    local reason = "Gr "..self:invalid_reason_str(min_growth, growth, max_growth)
    return false, reason
  end

  return true, " Gr -"
end

function Cultivate:valid_gain(gain)
  local max_gain = const.crop_bot.cultivate.MAX_GAIN
  local min_gain = self:min_gain()

  if (gain > max_gain) or (gain < min_gain) then
    local reason = "Ga "..self:invalid_reason_str(min_gain, gain, max_gain)
    return false, reason
  end

  return true, "Ga -"
end

function Cultivate:valid_resist(resist)
  local max_resist = self:max_resist()

  if resist > max_resist then
    local reason = "Re "..self:invalid_reason_str(0, resist, max_resist)
    return false, reason
  end

  return true, "Re -"
end

function Cultivate:valid_child(data_child)
  if self.crop_bot:is_weed(data_child) then
    self:increment_data(const.crop_bot.cultivate.DATA.WEEDS)
    return false, "weed"
  end

  if not self.crop_bot:is_plant(data_child) then
    return false, "not a plant"
  end

  if not self.crop_bot:same_species(data_child, const.crop_bot.cultivate.SPECIES) then
    self:increment_data(const.crop_bot.cultivate.DATA.CROSSES)
    return false, "wrong species"
  end

  if self.crop_bot:is_weedy_growth(data_child) then
    self:increment_data(const.crop_bot.cultivate.DATA.WEEDY_GROWTHS)
    return false, "weedy growth"
  end

  if self.num_loops == 1 then
    return true, nil
  end

  local growth, gain, resist = self.crop_bot:plant_stats(data_child)

  local valid_growth, reason_growth = self:valid_growth(growth)
  local valid_gain, reason_gain = self:valid_gain(gain)
  local valid_resist, reason_resist = self:valid_resist(resist)

  if (not valid_growth) or (not valid_gain) or (not valid_resist) then
    self:increment_data(const.crop_bot.cultivate.DATA.INVALID_STATS)
    return false, table.concat({reason_growth, reason_gain, reason_resist}, " | ")
  end

  return true, nil
end

function Cultivate:valid_parent(data_parent)
  if not self.crop_bot:is_plant(data_parent) then
    return false, "not a plant"
  end

  return true, nil
end

-- Assumes child is already validated
function Cultivate:lowest_parent(data_child)
  local lowest_parent_key = nil
  local highest_progress = 0

  for pos_str_parent, data_parent in pairs(self.data_parents) do
    local regressed = self:child_regression(data_child, data_parent)
    local progress = self:total_stat_improvement(data_child, data_parent)

    if (not regressed) and (progress > highest_progress) then
      lowest_parent_key = pos_str_parent
      highest_progress = progress
    end
  end

  local fail_reason = nil
  if num_regressions == self.num_parents then
    fail_reason = "regression"
    self:increment_data(const.crop_bot.cultivate.DATA.NO_PROGRESSES)
  elseif lowest_parent_key == nil then
    fail_reason = "no improvement"
    self:increment_data(const.crop_bot.cultivate.DATA.NO_PROGRESSES)
  end

  return lowest_parent_key, fail_reason
end

----------------------------------- Cultivation --------------------------------

function Cultivate:handle_validity()
  local scan_data = self.crop_bot:analyze_crop()

  local valid, reason
  if self.crop_bot:odd_pos() then
    valid, reason = self:valid_parent(scan_data)
  else
    valid, reason = self:valid_child(scan_data)
  end

  if (not self.crop_bot:is_empty_crop(scan_data)) and (not valid) then
    self.crop_bot:pluck(true, reason)
    self:increment_data(const.crop_bot.cultivate.DATA.PLUCKS)
    self:increment_data(const.crop_bot.cultivate.DATA.INVALIDS)
  elseif self.crop_bot:is_air(scan_data) then
    self.crop_bot:handle_air()
    valid = false
  end

  return valid
end

function Cultivate:handle_pos_data()
  if not self.crop_bot:odd_pos() then
    return
  end

  local scan_data = self.crop_bot:analyze_crop()
  local str_pos_curr = self.crop_bot:pos_str()
  self.data_parents[str_pos_curr] = scan_data

  if self:plant_maxed(scan_data) then
    self.num_maxed_parents = self.num_maxed_parents + 1
  end
end

function Cultivate:handle_initial_stats()
  if not self.crop_bot:odd_pos() then
    return
  end

  local scan_data = self.crop_bot:analyze_crop()
  local growth, gain, resist = self.crop_bot:plant_stats(scan_data)

  self:increment_stat_table(self.growth, growth)
  self:increment_stat_table(self.gain, gain)
  self:increment_stat_table(self.resist, resist)
end

function Cultivate:handle_replacement()
  local pos_child = self.crop_bot:pos()
  local data_child = self.crop_bot:analyze_crop()
  local pos_str_lowest_parent, fail_reason = self:lowest_parent(data_child)

  if pos_str_lowest_parent == nil then
    self.crop_bot:pluck(true, fail_reason)
    return
  end

  local pos_parent = coord:new_from_str(pos_str_lowest_parent)
  local data_parent = self.data_parents[pos_str_lowest_parent]

  self.crop_bot:replace_plants(pos_child, pos_parent, data_child, data_parent)
  self:increment_data(const.crop_bot.cultivate.DATA.SWAPS)

  local c_growth, c_gain, c_resist = self.crop_bot:plant_stats(data_child)
  local p_growth, p_gain, p_resist = self.crop_bot:plant_stats(data_parent)

  self:increment_stat_table(self.growth, c_growth)
  self:increment_stat_table(self.gain, c_gain)
  self:increment_stat_table(self.resist, c_resist)

  self:decrement_stat_table(self.growth, p_growth)
  self:decrement_stat_table(self.gain, p_gain)
  self:decrement_stat_table(self.resist, p_resist)

  self.data_parents[pos_str_lowest_parent] = data_child
end

function Cultivate:handle_patrol()
  local valid = self:handle_validity()
  self:handle_pos_data()

  local should_replace = valid and not self.crop_bot:odd_pos()

  if self.num_loops == 1 then
    self:handle_initial_stats()
  elseif self.num_loops > 1 and should_replace then
    self:handle_replacement()
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

  self.data = self:new_data_table()
  self.loop_deltas = self:new_data_table()

  self.crop_bot:clean_bind_dislocator()

  while not self:parents_maxed() do
    self.num_loops = self.num_loops + 1
    self.num_prev_maxed_parents = self.num_maxed_parents
    self.num_maxed_parents = 0

    -- No way to tail logs on OpenComputers, so this is a low-tech way to
    --   handle swapping between debugging strings and normal data prints
    if env.log_level >= const.log_levels.WARNING then
      self:print_data_screen()
    end

    logging.print("Loop "..tostring(self.num_loops), const.log_levels.INFO)

    self.crop_bot.patrol:patrol(self.handle_patrol, self, length, width)

    self.crop_bot:eject_all_misc()
    self.crop_bot:replenish_crops(false)

    self.loop_deltas = self:new_data_table()

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

