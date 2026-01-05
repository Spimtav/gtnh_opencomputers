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

function Min_Heap.Heap_Node:new(val, pos)
  local node = {
    val = val,
    elem = pos
  }
  setmetatable(node, self)
  self.__index = self
  return node
end

function Min_Heap.Heap_Node:print()
  print("Val: "..self.val)
  print("Elem: "..self.elem)
end

-- Binary Min Heap
Min_Heap.heap = {}

function Min_Heap:new()
  local new_heap = {}
  setmetatable(new_heap, self)
  self.__index = self
  return new_heap
end

function Min_Heap:insert(val, pos)
  local last_i = #self.heap + 1
  local node = Min_Heap.Heap_Node:new(val, pos)
  self.heap[last_i] = node
  self:bubble_up(last_i)
end

function Min_Heap:bubble_up(i)
  local node = self.heap[i]

  -- Base Case: root
  if i == 1 then return end

  -- Base Case: finished
  local parent_i = math.floor(i/2)
  local parent_node = self.heap[parent_i]

  if parent_node.val <= node.val then return end

  -- Tail Recursion
  self.heap[parent_i] = node
  self.heap[i] = parent_node
  return self:bubble_up(parent_i)
end


return Min_Heap

