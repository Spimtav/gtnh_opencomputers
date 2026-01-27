--[[
Duplication of plants with desired stats.

Operation:
- patrols the specified area
- plucks: weeds, crossbreeds, children that don't progress stats, children
          with weedy growths (Gr24+).
- replaces air blocks with crops
- behavior split into two modes:
  - seeds:
    - waits until children are mature then left-click harvests them
      - maximizes chance to drop a seed bag
    - repeats for the specified number of cycles
  - field:
    - plucks any children with:
      - growth < parents
      - gain < parents
      - resistance > parents
    - ignores all other children
    - repeats until field is full
- End state 1 (seeds):
  - odd coords are same parents you started with
  - even coords are empty (to prevent weeds)
- End state 2 (field):
  - odd coords are original parents
  - even coords are children of target species with stats >= the targets

Assumptions:
- everything from base crop_bot class
- Plants:
  - parents are capable of producing the desired children
    - ie: can be different species, different stats, ...
  - growth target is low enough (~20) that Gr24+ children do not appear.
    - in testing, Gr21 parents produced small # of Gr24s, gumming up operation
  - target resistance is 0

Config:
- set log level to >=WARN for cool stats screen
  - i would have had this be default and logs written to log file, but
    OpenComputers doesn't have a tail command or multiple terminal tabs
    so having both at once is of limited use.

To Dos:
- handling of weeded/empty parents and children
]]

term = require("term")

crop_bot = require("crop_bot")



local Propagate = {}


function Propagate:new()
  local new_prop = {
    crop_bot = crop_bot:new(),

    num_loops = 0,
    num_parents = 0,
    num_maxed_children = 0,
    maxed_child_poses = {},
    maxed_child_counts = {},

    data = {},
    loop_deltas = {}
  }
  new_prop["num_parents"] = new_prop["crop_bot"]:num_odds()
  setmetatable(new_prop, self)
  self.__index = self
  return new_prop
end

------------------------------- Accumulated Data -------------------------------

function Propagate:data_str(s)
  local data = self.data[s]
  local delta = self.loop_deltas[s]

  local data_str = tostring(data)..s

  if delta == 0 then
    return data_str
  end

  return data_str.."(+"..tostring(delta)..")"
end

function Propagate:increment_data(data_str)
  self.data[data_str] = self.data[data_str] + 1
  self.loop_deltas[data_str] = self.loop_deltas[data_str] + 1
end

-- Won't double-count children in field mode
function Propagate:increment_child_success_data(data_child, pos_str_child)
  if not self:is_mode_seeds() then
    if self.maxed_child_poses[pos_str_child] == nil then
      self.maxed_child_poses[pos_str_child] = 1
    else
      return
    end
  end

  local stat_str = self:full_stat_str(data_child)

  local data_str = const.crop_bot.propagate.TARGETS
  if self:child_improvement(data_child) then
    data_str = const.crop_bot.propagate.BETTERS
  end

  if self.maxed_child_counts[stat_str] == nil then
    self.maxed_child_counts[stat_str] = 0
  end

  self:increment_data(data_str)
  self.num_maxed_children = self.num_maxed_children + 1
  self.maxed_child_counts[stat_str] = self.maxed_child_counts[stat_str] + 1
end

function Propagate:new_data_table()
  local data_table = {}

  for _,v in pairs(const.crop_bot.propagate.DATA) do
    data_table[v] = 0
  end

  return data_table
end

--------------------------------- Prints ---------------------------------------

function Propagate:sorted_keys(t)
  local new_t = {}
  for k,_ in pairs(t) do
    table.insert(new_t, k)
  end

  table.sort(new_t)
  return new_t
end

function Propagate:print_data_screen()
  -- row data init
  local sorted_child_stats = self:sorted_keys(self.maxed_child_counts)
  local num_rows = #sorted_child_stats

  -- other data init
  local success_table = {
    self:data_str(const.crop_bot.propagate.DATA.TARGETS),
    self:data_str(const.crop_bot.propagate.DATA.BETTERS),
  }
  local pluck_table = {
    self:data_str(const.crop_bot.propagate.DATA.INVALID_STATS),
    self:data_str(const.crop_bot.propagate.DATA.WEEDS),
    self:data_str(const.crop_bot.propagate.DATA.WEEDY_GROWTHS)
  }

  local success_stats = "("..table.concat(success_table, "|")..")"
  local pluck_stats = "("..table.concat(pluck_table, "|")..")"

  -- screen updates
  term.clear()

  print("Loop: "..tostring(self.num_loops))
  print(string.rep("=", 30))
  print("Successes: "..tostring(self.num_maxed_children).." "..success_stats)
  print("Crosses: "..self:data_str(const.crop_bot.propagate.DATA.CROSSES))
  print("Plucks: "..self:data_str(const.crop_bot.propagate.DATA.PLUCKS).." "..pluck_stats)

  print("Child Counts:")
  print(string.rep("_", 15))
  for i=1,num_rows do
    local stat_key = sorted_child_stats[i]
    local stat_count = self.maxed_child_counts[stat_key]

    print(stat_key..": "..tostring(stat_count))
  end
end

-------------------------------- Crop Stats ------------------------------------

function Propagate:invalid_reason_str(invalid_stat, target_stat)
  local str_invalid = tostring(invalid_stat)
  local str_target = tostring(target_stat)

  return "[("..str_invalid.."),"..str_target.."]"
end

function Propagate:full_stat_str(scan_data)
  local growth, gain, resist = self.crop_bot:plant_stats(data_child)

  local str_growth = tostring(growth).."Gr"
  local str_gain = tostring(gain).."Ga"
  local str_resist = tostring(resist).."Re"

  return table.concat({str_growth, str_gain, str_resist}, "|")
end

function Propagate:child_improvement(data_child)
  local growth, gain, resist = self.crop_bot:plant_stats(data_child)

  local better_growth = growth > env.propagate.MIN_GROWTH
  local better_gain = gain > env.propagate.MIN_GAIN
  local better_resist = resist < env.propagate.MAX_RESIST

  return better_growth or better_gain or better_resist
end

------------------------------------- Checks -----------------------------------

function Propagate:is_mode_seeds()
  return env.propagate.MODE == const.crop_bot.propagate.MODE_SEEDS
end

function Propagate:valid_growth(growth)
  local min_growth = env.propagate.MIN_GROWTH

  if growth < min_growth then
    local reason = "Gr "..self:invalid_reason_str(growth, min_growth)
    return false, reason
  end

  return true, " Gr -"
end

function Propagate:valid_gain(gain)
  local min_gain = env.propagate.MIN_GAIN

  if gain < min_gain then
    local reason = "Ga "..self:invalid_reason_str(gain, min_gain)
    return false, reason
  end

  return true, "Ga -"
end

function Propagate:valid_resist(resist)
  local max_resist = env.propagate.MAX_RESIST

  if resist > max_resist then
    local reason = "Re "..self:invalid_reason_str(resist, max_resist)
    return false, reason
  end

  return true, "Re -"
end

function Propagate:valid_child(data_child)
  if self.crop_bot:is_weed(data_child) then
    self:increment_data(const.crop_bot.propagate.DATA.WEEDS)
    return false, "weed"
  end

  if not self.crop_bot:is_plant(data_child) then
    return false, "not a plant"
  end

  if not self.crop_bot:same_species(data_child, env.propagate.SPECIES) then
    self:increment_data(const.crop_bot.propagate.DATA.CROSSES)
    return false, "wrong species"
  end

  if self.crop_bot:is_weedy_growth(data_child) then
    self:increment_data(const.crop_bot.propagate.DATA.WEEDY_GROWTHS)
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
    self:increment_data(const.crop_bot.propagate.DATA.INVALID_STATS)
    return false, table.concat({reason_growth, reason_gain, reason_resist}, " | ")
  end

  return true, nil
end

function Propagate:valid_parent(data_parent)
  if not self.crop_bot:is_plant(data_parent) then
    return false, "not a plant"
  end

  return true, nil
end

function Propagate:propagation_complete()
  if self.num_loops == 0 then
    return false
  end

  if self:is_mode_seeds() then
    return self.num_loops > env.propagate.MAX_LOOPS_SEEDS
  else
    return self.num_maxed_children == self.num_parents
  end
end

----------------------------------- Propagation --------------------------------

function Propagate:handle_validity()
  local scan_data = self.crop_bot:analyze_crop()

  local valid, reason
  if self.crop_bot:odd_pos() then
    valid, reason = self:valid_parent(scan_data)
  else
    valid, reason = self:valid_child(scan_data)
  end

  if self.crop_bot:is_air(scan_data) then
    self.crop_bot:handle_air()
    valid = false
  elseif (not self.crop_bot:is_empty_crop(scan_data)) and (not valid) then
    self.crop_bot:pluck(true, reason)
    self:increment_data(const.crop_bot.propagate.DATA.PLUCKS)
  end

  return valid
end

function Propagate:handle_child()
  local data_child = self.crop_bot:analyze_crop()
  local pos_str_child = self.crop_bot:pos_str()

  if self:is_mode_seeds() and self.crop_bot:is_mature(data_child) then
    self.crop_bot:pluck(true, "collecting seed from ideal-statted child")
    self:increment_child_success_data(data_child, pos_str_child)
  elseif not self:is_mode_seeds() then
    self:increment_child_success_data(data_child, pos_str_child)
  end
end

function Propagate:handle_patrol()
  local valid = self:handle_validity()

  if valid and not self.crop_bot:odd_pos() then
    self:handle_child()
  end
end

function Propagate:handle_cleanup()
  if not self.crop_bot:odd_pos() then
    self.crop_bot:clear_plot()
  end
end


function Propagate:propagate()
  local length = env.propagate.PLOT_LENGTH
  local width = env.propagate.PLOT_WIDTH

  self.data = self:new_data_table()
  self.loop_deltas = self:new_data_table()

  while not self:propagation_finished() do
    self.num_loops = self.num_loops + 1

    -- No way to tail logs on OpenComputers, so this is a low-tech way to
    --   handle swapping between debugging strings and normal data prints
    if env.log_level >= const.log_levels.WARNING then
      self:print_data_screen()
    end

    self.loop_deltas = self:new_data_table()

    logging.print("Loop "..tostring(self.num_loops), const.log_levels.INFO)

    self.crop_bot.patrol:patrol(self.handle_patrol, self, length, width)

    self.crop_bot:eject_all_misc()
    self.crop_bot:replenish_crops(false)

    logging.print("\n"..string.rep("_", 30), const.log_levels.INFO)
  end

  if self:is_mode_seeds() then
    print("\nCleaning up child plots")
    self.crop_bot.patrol:patrol(self.handle_cleanup, self, length, width)
  end

  self.crop_bot:eject_all_misc()
end


function Propagate.main()
  local prop = Propagate:new()

  prop:propagate()

  print("Finished propagating")
end


return Propagate

