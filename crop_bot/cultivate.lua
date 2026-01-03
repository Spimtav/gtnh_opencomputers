--[[
Notes:
- plot assumptions:
  - plot is made up of soil that can accept IC2 crop sticks
  - plot is one tile below the robot
  - plot is small enough that robot won't run out of energy during operation
- crop assumptions:
  - initial crops to optimize are placed at odd coords
  - all odd coords are pre-planted with identical crop-types to stat-up
  - no pre-planted crops have any stat that's greater than the desired stats
- robot assumptions:
  - robot has an equipped Crops++ spade (which is unbreakable)
  - robot has a Thaumic Tinkerer transvector binder in its inventory
- block assumptions:
  - charger is 1 block left of bottom left corner of plot
  - IC2 crop stick storage container:
    - 1 block down of bottom left corner of plot
    - infinitely restocked with crop sticks via another system
    - never depletes
]]

package.loaded.move = nil
package.loaded.patrol = nil

BOT = require("robot")
GEO = require("component").geolyzer
MOVE = require("move")
PATROL = require("patrol")

local MAX_GROWTH = 21
local MAX_GAIN = 32
local MAX_RESISTANCE = 0

local PARENT_CROPS = {}
local CHILD_CROPS = {}


function pos_str()
  local x = PATROL.POS_CURR[1]
  local y = PATROL.POS_CURR[2]

  return x..","..y
end

function crop_stat_str(stat_table)
  local name = stat_table["crop:name"]
  local growth = stat_table["crop:growth"]
  local gain = stat_table["crop:gain"]
  local resistance = stat_table["crop:resistance"]

  return name..": "..growth..","..gain..","..resistance
end

function odd_pos()
  local x = PATROL.POS_CURR[1]
  local y = PATROL.POS_CURR[2]

  return (x+y % 2) == 1
end

function print_crop_table(table)
  for k,v in pairs(table) do
    print(k..": ["..crop_stat_str(v).."]")
  end
end

function cultivate()
  local crop_data = GEO.analyze(MOVE.FACINGS["D"])

  local crop_table = CHILD_CROPS
  if odd_pos() then
    crop_table = PARENT_CROPS
  end

  crop_table[pos_str()] = crop_data
end


function main()
  PATROL.patrol(cultivate, 2, 2)

  print_crop_table(PARENT_CROPS)
  print_crop_table(CHILD_CROPS)
end


main()

