--[[
Notes:
- simple representation of an X,Y coordinate
- I basically just need this so i can override __tostring()
]]

local Coord = {}


function Coord:new(x, y)
  local coord = {
    x = x,
    y = y
  }
  setmetatable(coord, self)
  self.__index = self
  return coord
end

function Coord:new_from_str(s)
  local _, _, str_x, str_y = s:find("{(%d+),(%d+)}")
  local x = tonumber(str_x)
  local y = tonumber(str_y)

  return Coord:new(x, y)
end

function Coord:clone()
  return Coord:new(self.x, self.y)
end

function Coord:set_to(coord)
  self.x = coord.x
  self.y = coord.y
end

function Coord:__tostring()
  return "{"..self.x..","..self.y.."}"
end

function Coord:reset()
  self.x = 0
  self.y = 0
end

function Coord:set_x(x)
  self.x = x
end

function Coord:set_y(y)
  self.y = y
end


return Coord

