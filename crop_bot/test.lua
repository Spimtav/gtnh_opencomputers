--[[
Notes: 
  - assumes charger is 1 block south of bottom-left corner of plot.
]]

BOT = require("robot")
NAV = component.navigation

PLOT_LENGTH = 3
PLOT_WIDTH = 3
POS_START = {0, 0}
FACINGS = {
  ["N"] = 2,
  ["S"] = 3,
  ["W"] = 4,
  ["E"] = 5
}
MC_FACINGS = {
  [2] = "N",
  [3] = "S",
  [4] = "W",
  [5] = "E"
}
TURNS = {
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


function facing_x()
  local dir_curr = NAV.getFacing()

  return dir_curr == FACINGS["W"] or dir_curr == FACINGS["E"]
end

function facing_y()
  local dir_curr = NAV.getFacing()

  return dir_curr == FACINGS["N"] or dir_curr == FACINGS["S"]
end

function face_dir(dir_new)
  local dir_curr = MC_FACINGS[NAV.getFacing()]

  if dir_curr == dir_new then
    return
  end

  BOT[TURNS[dir_curr..dir_new]]()
end

function move_function(dist_new)
  local dir_curr = NAV.getFacing()

  if dist_new > 0 and (dir_curr == FACINGS["N"] or dir_curr == FACINGS["E"]) then
    return BOT.forward
  elseif dist_new < 0 and (dir_curr == FACINGS["S"] or dir_curr == FACINGS["W"]) then
    return BOT.forward
  end
  
  return BOT.back
end

function move_dist(dist_new)
  local move_func = move_function(dist_new)
  for _=1,math.abs(dist_new) do
    move_func()
  end
end

function travel_pos(curr_pos, new_pos)
  local dist_y = new_pos[1] - curr_pos[1]
  local dist_x = new_pos[2] - curr_pos[2]

  if facing_x() then
    move_dist(dist_x)
    dist_x = 0
  end
  if facing_y() then
    move_dist(dist_y)
    dist_y = 0
  end

  face_dir("E")
  move_dist(dist_x)
  face_dir("N")
  move_dist(dist_y)
end


function main()
  --local pos_cur = POS_START
end

-- main()



