--[[
Notes:
  - placement assumptions:
    - patrollable area is a solid rectangle
    - robot starts in bottom left corner of patrollable area
    - patrollable area is pointed towards true north
]]


local Patrol = {}

local bot = require("robot")
local move = require("move")
local coord = require("coord")


function Patrol:new()
  local new_patrol = {
    pos_start = coord:new(0,0),
    pos_curr = coord:new(0,0)
  }
  setmetatable(new_patrol, self)
  self.__index = self
  return new_patrol
end

function Patrol:reset_pos()
  self.pos_curr:reset()
end

function Patrol:even_row(row)
  return (row % 2) == 0
end

function Patrol:travel_y(y)
  if y > 0 then
    move.travel_dir("N", 1)
    self.pos_curr:set_y(self.pos_curr.y + 1)
  end

  logging.print(tostring(self), const.log_levels.DEBUG)
end

function Patrol:travel_x(x, y)
  if x > 0 then
    bot.forward()

    local dist = -1
    if self:even_row(y) then
      dist = 1
    end

    self.pos_curr:set_x(self.pos_curr.x + dist)
  end

  logging.print(tostring(self), const.log_levels.DEBUG)
end

function Patrol:travel_start()
  move.travel_pos(self.pos_curr, self.pos_start)
  self:reset_pos()

  logging.print("Reset to charger", const.log_levels.DEBUG)
end

function Patrol:face_inward_x(y)
  if self:even_row(y) then
    move.face_dir("E")
  else
    move.face_dir("W")
  end
end

function Patrol:__tostring()
  return "At: ("..self.pos_curr.x..", "..self.pos_curr.y..")"
end


function Patrol:patrol(bot_func, bot_obj, patrol_length, patrol_width)
  self:reset_pos()

  for y=0,(patrol_length-1) do
    self:travel_y(y)
    self:face_inward_x(y)

    for x=0,(patrol_width-1) do
      self:travel_x(x, y)

      bot_func(bot_obj)
    end
  end

  self:travel_start()
end


return Patrol

