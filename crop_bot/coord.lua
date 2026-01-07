--[[
Notes:
- simple representation of an X,Y coordinate
- I basically just need this so i can override __tostring()
]]

if Coord then return end

local Coord = {}

function Coord:new(x,y)
  local coord = {
    x = x,
    y = y
  }
  setmetatable(coord, self)
  self.__index = self
  return coord
end

function Coord:__tostring()
  return "{"..self.x..","..self.y.."}"
end

return Coord

