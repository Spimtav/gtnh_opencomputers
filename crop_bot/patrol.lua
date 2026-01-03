--[[
Notes: 
  - assumes charger is 1 block south of bottom-left corner of plot.
]]

package.loaded.move = nil

local BOT = require("robot")
local MOVE = require("move")

local PLOT_LENGTH = 3
local PLOT_WIDTH = 3
local POS_START = {0, 0}

local pos_curr = {0, 0}


function reset_pos()
  pos_curr[1] = POS_START[1]
  pos_curr[2] = POS_START[2]
end

function odd_row(row)
  return (row % 2) == 1
end

function travel_y(y)
  if y > 1 then
    MOVE.travel_dir("N", 1)
    pos_curr[2] = pos_curr[2] + 1
  end
 
  print_pos()
end

function travel_x(y)
  BOT.forward()
  
  if odd_row(y) then
    pos_curr[1] = pos_curr[1] + 1
  else
    pos_curr[1] = pos_curr[1] - 1
  end 
  
  print_pos()
end

function travel_start()
  print("Resetting to charger")
  MOVE.travel_pos(pos_curr, POS_START)
  reset_pos()
end

function face_inward_x(y)
  if odd_row(y) then
    MOVE.face_dir("E")
  else
    MOVE.face_dir("W")
  end
end

function print_pos() 
  print("At: ("..pos_curr[1]..", "..pos_curr[2]..")")
end


function main()
  reset_pos()
  
  for rounds=1,2 do
    for y=1,PLOT_LENGTH do
      travel_y(y)
      face_inward_x(y)
 
      for x=1,PLOT_WIDTH do
        travel_x(y)
      end
    end
  
    travel_start()
  end
end

main()

