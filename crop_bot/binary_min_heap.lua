--[[
Notes:
- each element of heap is a table consisting of:
  - val: node's value
  - elems: unordered table of elements with same val
]]

if Min_Heap then return end

local Min_Heap = {}

-- Heap node
Min_Heap.Heap_Node = {}

function Min_Heap.Heap_Node:new(val)
  local node = {
    val = val or 0,
    elems = {}
  }
  setmetatable(node, self)
  self.__index = self
  return node
end

function Min_Heap.Heap_Node:is_empty()
  return next(self.elems) == nil
end

function Min_Heap.Heap_Node:append(elem)
  table.insert(self.elems, elem)
end

function Min_Heap.Heap_Node:remove()
  return table.remove(self.elems)
end

function Min_Heap.Heap_Node:print()
  print("Val: "..self.val)
  print("Elems:")
  for _,i in ipairs(self.elems) do
    print("  ("..i[1]..","..i[2]..")")
  end
end

-- Binary Min Heap
Min_Heap.heap = {}
Min_Heap.test = {}

function Min_Heap:new()
  local new_heap = {}
  setmetatable(new_heap, self)
  self.__index = self
  return new_heap
end

function Min_Heap:set_test_val(i)
  self.test = i
end


return Min_Heap

