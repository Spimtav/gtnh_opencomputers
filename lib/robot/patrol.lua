--[[
Notes:
  - placement assumptions:
    - charger is adjacent to bottom left corner of patrollable area
    - patrollable area is a solid rectangle
]]


local Patrol = {}

local BOT = require("robot")
local MOVE = require("move")
local COORD = require("coord")


function Patrol:new()
  local patrol = {
    pos_start = COORD:new(0,0),
    pos_curr = COORD:new(0,0)
  }
  setmetatable(patrol, self)
  self.__index = self
  return patrol
end

function Patrol:reset_pos()
  self.pos_curr:reset()
end

function Patrol:even_row(row)
  return (row % 2) == 0
end

function Patrol:travel_y(y)
  if y > 0 then
    MOVE.travel_dir("N", 1)
    self.pos_curr:set_y(self.pos_curr.y + 1)
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

    patrol.POS_CURR.x = patrol.POS_CURR.x + dist
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
  print("At: ("..patrol.POS_CURR.x..", "..patrol.POS_CURR.y..")")
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

