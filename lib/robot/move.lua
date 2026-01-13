--[[
Notes:
- move optimized to minimize turns, in order to save robot's battery
]]


local move = {}

local bot = require("robot")
local nav = require("component").navigation


move.TURNS = {
  ["NS"] = "turnAround",
  ["NW"] = "turnLeft",
  ["NE"] = "turnRight",
  ["SN"] = "turnAround",
  ["SW"] = "turnRight",
  ["SE"] = "turnLeft",
  ["WN"] = "turnRight",
  ["WS"] = "turnLeft",
  ["WE"] = "turnAround",
  ["EN"] = "turnLeft",
  ["ES"] = "turnRight",
  ["EW"] = "turnAround"
}


function move.facing_x()
  local dir_curr = nav.getFacing()

  return dir_curr == const.FACINGS[const.W] or dir_curr == const.FACINGS[const.E]
end

function move.facing_y()
  local dir_curr = nav.getFacing()

  return dir_curr == const.FACINGS[const.N] or dir_curr == const.FACINGS[const.S]
end

function move.face_dir(dir_new)
  local dir_curr = const.MC_FACINGS[nav.getFacing()]

  if dir_curr == dir_new then
    return
  end

  bot[move.TURNS[dir_curr..dir_new]]()
end

function move.move_func_plane(dist_new)
  local dir_curr = nav.getFacing()

  if dist_new > 0 and (dir_curr == const.FACINGS[const.N] or dir_curr == const.FACINGS[const.E]) then
    return bot.forward
  elseif dist_new < 0 and (dir_curr == const.FACINGS[const.S] or dir_curr == const.FACINGS[const.W]) then
    return bot.forward
  end

  return bot.back
end

function move.move_func_relative(dist)
  if dist > 0 then
    return bot.forward
  end

  return bot.back
end

function move.travel(dist, move_func)
  for _=1,math.abs(dist) do
    move_func()
  end
end

function move.travel_plane(dist_plane)
  local move_func = move.move_func_plane(dist_plane)
  move.travel(dist_plane, move_func)
end

function move.travel_relative(dist_rel)
  local move_func = move.move_func_relative(dist_rel)
  move.travel(dist_rel, move_func)
end

function move.travel_pos(curr_pos, new_pos)
  local dist_x = new_pos.x - curr_pos.x
  local dist_y = new_pos.y - curr_pos.y

  if move.facing_y() then
    move.travel_plane(dist_y)
    move.face_dir(const.E)
    move.travel_plane(dist_x)
  elseif move.facing_x() then
    move.travel_plane(dist_x)
    move.face_dir(const.N)
    move.travel_plane(dist_y)
  end
end

function move.travel_dir(dir, dist)
  move.face_dir(dir)
  move.travel_relative(dist)
end

function move.travel_forward(dist)
  move.travel(dist, bot.forward)
end

function move.travel_back(dist)
  move.travel(dist, bot.back)
end

function move.travel_left(dist)
  bot.turnLeft()
  move.travel(dist, bot.forward)
end

function move.travel_right(dist)
  bot.turnRight()
  move.travel(dist, bot.forward)
end


return move

