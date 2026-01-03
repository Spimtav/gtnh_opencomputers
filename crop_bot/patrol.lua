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

local pos_curr


function reset_pos()
  pos_curr[1] = POS_START[1]
  pos_curr[2] = POS_START[2]
end

function odd_row(row)
  return (row % 2) == 1
end


reset_pos()

for rounds=1,2 do
  MOVE.face_dir("N")
  for y=1,PLOT_LENGTH do
    if y > 1 then
      MOVE.travel_dir("N", 1)
      pos_curr[2] = pos_curr[2] + 1
      print("At: ("..pos_curr[1]..", "..pos_curr[2]..")")
    end

    if odd_row(y) then
      MOVE.face_dir("E")
    else
      MOVE.face_dir("W")
    end

    for x=1,PLOT_WIDTH do
      BOT.forward()
      if odd_row(y) do
        pos_curr[1] = pos_curr[1] + 1
      else do
        pos_curr[1] = pos_curr[1] - 1
      end

      print("At: ("..pos_curr[1]..", "..pos_curr[2]..")")
    end
  end

  print("Resetting to charger")
  MOVE.travel_pos(pos_curr, POS_START)
  reset_pos()
end

