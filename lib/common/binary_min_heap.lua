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
  print("Val: "..tostring(self.val))
  print("Elem: "..tostring(self.elem))
end

function Min_Heap.Heap_Node:__tostring()
  return tostring(self.val)..":"..tostring(self.elem)
end

-- Binary Min Heap
Min_Heap.heap = {}

function Min_Heap:new()
  local new_heap = {}
  setmetatable(new_heap, self)
  self.__index = self
  return new_heap
end

-- Note: i am so proud of this holy dimbledop, this was deceptively nontrivial u_u
function Min_Heap:depth_strings(i, depth)
  local depth_max = math.floor(math.log(#self.heap) / math.log(2))
  local node = self.heap[i]
  local node_str = tostring(node or "")

  -- Base Case: deepest depth
  if depth == depth_max then return {[depth] = node_str} end

  -- Recursion
  local i_child1 = i * 2
  local i_child2 = i * 2 + 1

  local depth_strs1 = self:depth_strings(i_child1, depth+1, len_parent_max)
  local depth_strs2 = self:depth_strings(i_child2, depth+1, len_parent_max)

  local str1 = depth_strs1[depth_max]
  local str2 = depth_strs2[depth_max]

  if #str1 > 0 and #str2 == 0 then depth_strs2[depth_max] = string.rep(" ", #str1) end

  local sep_size = 1
  if #node_str > (#str1 + #str2) then
    sep_size = #node_str
  end

  local joined_depth_strs = {}
  for d=depth+1,depth_max do
    joined_depth_strs[d] = depth_strs1[d]..string.rep("  ", sep_size)..depth_strs2[d]
  end

  local parent_sep_size = #joined_depth_strs[depth_max] - #node_str
  local sep_size_l = math.ceil(parent_sep_size / 2)
  local sep_size_r = parent_sep_size - sep_size_l
  local sep_l = string.rep(" ", sep_size_l)
  local sep_r = string.rep(" ", sep_size_r)

  joined_depth_strs[depth] = sep_l..node_str..sep_r

  return joined_depth_strs
end

function Min_Heap:print()
  if #self.heap == 0 then return print("<empty>") end
  local depth_strings = self:depth_strings(1, 0)

  for d=0,#depth_strings do
    print(depth_strings[d])
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


