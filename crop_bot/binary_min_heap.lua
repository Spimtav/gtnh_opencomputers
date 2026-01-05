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

function Min_Heap.Heap_Node:can_bubble_down(node)
  if node == nil then return false end

  return self.val > node.val
end

function Min_Heap.Heap_Node:print()
  print("Val: "..self.val)
  print("Elem: "..self.elem)
end

function Min_Heap.Heap_Node:str()
  return self.val..":"..self.elem.str()
end

-- Binary Min Heap
Min_Heap.heap = {}

function Min_Heap:new()
  local new_heap = {}
  setmetatable(new_heap, self)
  self.__index = self
  return new_heap
end

function Min_Heap:print()
  if #self.heap == 0 then print("<empty>") return end

  local depth_nodes = {}
  for i,node in ipairs(self.heap) do
    local depth_curr = math.floor(math.log(i) / math.log(2))

    if depth_nodes[depth_curr] == nil then depth_nodes[depth_curr] = {} end

    table.insert(depth_nodes[depth_curr], node)
  end

  local depth_max = math.floor(math.log(#self.heap) / math.log(2))
  for depth_curr=0,depth_max do
    local nodes = depth_nodes[depth_curr]
    local height_curr = depth_max - depth_curr

    local sep_size_base = "    "
    local sep_size = (height_curr + 1) ^ 2
    local sep = string.rep(sep_size_base, sep_size)

    local depth_str = ""
    for i,node in ipairs(nodes) do
      if i == 1 then
        depth_str = depth_str..tostring(node)
      else
        depth_str = depth_str..sep..tostring(node)
      end
    end

    if depth_curr ~= depth_max then
      depth_str = sep..depth_str
    end

    print(depth_str)
  end
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

function Min_Heap:min_val()
  if #self.heap == 0 then return nil end

  return self.heap[1].val
end

function Min_Heap:pop()
  if #self.heap == 0 then return end

  local head = self.heap[1]
  self.heap[1] = self.heap[#self.heap]

  table.remove(self.heap)
  self:bubble_down(1)

  return head
end

function Min_Heap:can_bubble_down(child)
  if child == nil then return false end

  return self.val > child.val
end

function Min_Heap:bubble_down(i)
  -- Base Case: nothing to do
  if #self.heap == 0 then return end

  -- Base Case: leaf
  local i_child1 = i * 2
  local i_child2 = i * 2 + 1

  if i_child1 > #self.heap then return end

  -- Base Case: finished
  local parent = self.heap[i]
  local child1 = self.heap[i_child1]
  local child2 = self.heap[i_child2]

  if (not parent:can_bubble_down(child1)) and (not parent:can_bubble_down(child2)) then return end

  -- Tail Recursion
  local i_best_child = i_child1
  local best_child = child1
  if child2 ~= nil and child2.val < child1.val then
    i_best_child = i_child2
    best_child = child2
  end

  self.heap[i] = best_child
  self.heap[i_best_child] = parent

  return self:bubble_down(i_best_child)
end


return Min_Heap


