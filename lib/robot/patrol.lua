--[[
Notes: 
  - placement assumptions:
    - charger is adjacent to bottom left corner of patrollable area
    - patrollable area is a solid rectangle
]]

if patrol then return end

local patrol = {}

package.loaded.move = nil

local BOT = require("robot")
local MOVE = require("move")

patrol.POS_START = {0, 0}
patrol.POS_CURR = {0, 0}


function patrol.reset_pos()
  patrol.POS_CURR[1] = patrol.POS_START[1]
  patrol.POS_CURR[2] = patrol.POS_START[2]
end

function patrol.even_row(row)
  return (row % 2) == 0
end

function patrol.travel_y(y)
  if y > 0 then
    MOVE.travel_dir("N", 1)
    patrol.POS_CURR[2] = patrol.POS_CURR[2] + 1
  end
 
  patrol.print_pos()
end

function patrol.travel_x(x, y)
  if x > 0 then
    BOT.forward()

    local dist = -1
    if patrol.even_row(y) then
      dist = 1
    end

    patrol.POS_CURR[1] = patrol.POS_CURR[1] + dist
  end
  
  patrol.print_pos()
end

function patrol.travel_start()
  print("Resetting to charger")
  MOVE.travel_pos(patrol.POS_CURR, patrol.POS_START)
  patrol.reset_pos()
end

function patrol.face_inward_x(y)
  if patrol.even_row(y) then
    MOVE.face_dir("E")
  else
    MOVE.face_dir("W")
  end
end

function patrol.print_pos() 
  print("At: ("..patrol.POS_CURR[1]..", "..patrol.POS_CURR[2]..")")
end


function patrol.patrol(bot_func, patrol_length, patrol_width)
  patrol.reset_pos()
  
  local func_calls = 0
  for y=0,(patrol_length-1) do
    patrol.travel_y(y)
    patrol.face_inward_x(y)
 
    for x=0,(patrol_width-1) do
      patrol.travel_x(x, y)

      bot_func()
      func_calls = func_calls + 1
      print("Func calls: "..func_calls)
    end
  end

  patrol.travel_start()
end

return patrol

