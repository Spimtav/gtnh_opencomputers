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
    pos_curr = coord:new(0,0),
    pos_prev = coord:new(0,0)
  }
  setmetatable(new_patrol, self)
  self.__index = self
  return new_patrol
end

function Patrol:even_row(row)
  return (row % 2) == 0
end

function Patrol:travel_y(y)
  if y > 0 then
    move.travel_dir(const.N, 1)
    self.pos_prev:set_to(self.pos_curr)
    self.pos_curr:set_y(self.pos_curr.y + 1)
  end

  logging.print(tostring(self), const.log_levels.DEBUG)
end

function Patrol:travel_x(x, y)
  if x > 0 then
    local pos_dist = -1
    if self:even_row(y) then
      pos_dist = 1
      move.travel_dir(const.E, 1)
    else
      move.travel_dir(const.W, 1)
    end

    self.pos_prev:set_to(self.pos_curr)
    self.pos_curr:set_x(self.pos_curr.x + pos_dist)
  end

  logging.print(tostring(self), const.log_levels.DEBUG)
end

function Patrol:travel_pos(coord, save_prev_coord)
  if save_prev_coord then
    self.pos_prev:set_to(self.pos_curr)
  end

  move.travel_pos(self.pos_curr, coord)

  self.pos_curr:set_to(coord)

  logging.print("Traveled to: "..tostring(coord), const.log_levels.DEBUG)
end

function Patrol:travel_start()
  self:travel_pos(self.pos_start, true)

  logging.print("Reset to charger", const.log_levels.DEBUG)
end

function Patrol:travel_prev()
  self:travel_pos(self.pos_prev, true)

  logging.print("Returned to prev position: "..tostring(self.pos_curr), const.log_levels.DEBUG)
end

function Patrol:__tostring()
  return "At: ("..self.pos_curr.x..", "..self.pos_curr.y..")"
end


function Patrol:patrol(bot_func, bot_obj, patrol_length, patrol_width)
  for y=0,(patrol_length-1) do
    self:travel_y(y)

    for x=0,(patrol_width-1) do
      self:travel_x(x, y)

      bot_func(bot_obj)
    end
  end

  self:travel_start()
end


return Patrol

