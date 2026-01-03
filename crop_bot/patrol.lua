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


function odd_row(row)
  (row % 2) == 1
end

local pos_curr = POS_START

for rounds=1,1 do 
  MOVE.face_dir("N")
  for y=1,PLOT_HEIGHT do
    if odd_row(y) then
      MOVE.face_dir("E")
    else
      MOVE.face_dir("W")
    end
    
    if y > 1 then
      BOT.forward()
      pos_curr[2] = pos_curr[2] + 1
      print("At: ("..pos_curr[1]..", "..pos_curr[2]..")")
    end

    for x=1,PLOT_WIDTH do
      BOT.forward()
      pos_curr[1] = pos_curr[1] + 1
      print("At: ("..pos_curr[1]..", "..pos_curr[2]..")")
    end
  end

  print("Resetting to charger")
  MOVE.travel_pos(pos_curr, POS_START)
  pos_curr = POS_START
end

