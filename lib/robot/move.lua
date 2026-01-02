--[[
Notes:
- move optimized to minimize turns, in order to save robot's battery
]]

if move then return end

local move = {}

BOT = require("robot")
NAV = component.navigation

move.FACINGS = {
  ["N"] = 2,
  ["S"] = 3,
  ["W"] = 4,
  ["E"] = 5
}
move.MC_FACINGS = {
  [2] = "N",
  [3] = "S",
  [4] = "W",
  [5] = "E"
}
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
  local dir_curr = NAV.getFacing()

  return dir_curr == move.FACINGS["W"] or dir_curr == move.FACINGS["E"]
end

function move.facing_y()
  local dir_curr = NAV.getFacing()

  return dir_curr == move.FACINGS["N"] or dir_curr == move.FACINGS["S"]
end

function move.face_dir(dir_new)
  local dir_curr = move.MC_FACINGS[NAV.getFacing()]

  if dir_curr == dir_new then
    return
  end

  BOT[move.TURNS[dir_curr..dir_new]]()
end

function move.move_function(dist_new)
  local dir_curr = NAV.getFacing()

  if dist_new > 0 and (dir_curr == move.FACINGS["N"] or dir_curr == move.FACINGS["E"]) then
    return BOT.forward
  elseif dist_new < 0 and (dir_curr == move.FACINGS["S"] or dir_curr == move.FACINGS["W"]) then
    return BOT.forward
  end
  
  return BOT.back
end

function move.move_dist(dist_new)
  local move_func = move.move_function(dist_new)
  for _=1,math.abs(dist_new) do
    move_func()
  end
end

function move.travel_pos(curr_pos, new_pos)
  local dist_y = new_pos[1] - curr_pos[1]
  local dist_x = new_pos[2] - curr_pos[2]

  if facing_x() then
    move.move_dist(dist_x)
    move.face_dir("N")
    move.move_dist(dist_y)
  end
  if facing_y() then
    move.move_dist(dist_y)
    move.face_dir("E")
    move.move_dist(dist_x)
  end
end

function move.travel_dir(dir, dist)
  move.face_dir(dir)
  move.move_dist(dist)
end

return move

