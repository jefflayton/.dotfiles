-- Smarter pane moving.
--
-- move_pane{ direction = "left" | "right" | "up" | "down" }
--   * If a pane sits next to the focused one in that direction, swap with it.
--   * Otherwise the pane is already at that edge of its split, so re-split it
--     beside the pane it shares a border with: stacked panes become side by
--     side and side-by-side panes become stacked.
--
-- Swaps go through the app's own pane.move (animated). The edge re-split has
-- no client equivalent, so it uses session.move_block and is instant.

local EPS = 1e-6

local DIRS = {
  left = { axis = "x", sign = -1, split = "horizontal", side = "before" },
  right = { axis = "x", sign = 1, split = "horizontal", side = "after" },
  up = { axis = "y", sign = -1, split = "vertical", side = "before" },
  down = { axis = "y", sign = 1, split = "vertical", side = "after" },
}

-- rect = { x, y, w, h } in window fractions.
local function span(rect, axis)
  if axis == "x" then
    return rect[1], rect[1] + rect[3]
  end
  return rect[2], rect[2] + rect[4]
end

local function other_axis(axis)
  return axis == "x" and "y" or "x"
end

local function overlap(a, b, axis)
  local a0, a1 = span(a, axis)
  local b0, b1 = span(b, axis)
  return math.min(a1, b1) - math.max(a0, b0)
end

-- True when `b` touches `a` on the side `dir` points to.
local function abuts(a, b, dir)
  local a0, a1 = span(a, dir.axis)
  local b0, b1 = span(b, dir.axis)
  if dir.sign > 0 then
    return math.abs(b0 - a1) < EPS
  end
  return math.abs(b1 - a0) < EPS
end

local function leaves(node, out)
  out = out or {}
  if node.block_id then
    out[#out + 1] = node
  elseif node.split then
    leaves(node.split.before, out)
    leaves(node.split.after, out)
  end
  return out
end

-- Returns the leaf for block_id and the chain of ancestor nodes above it.
local function find(node, block_id, path)
  path = path or {}
  if node.block_id == block_id then
    return node, path
  end
  if node.split then
    path[#path + 1] = node
    local leaf, p = find(node.split.before, block_id, path)
    if leaf then
      return leaf, p
    end
    leaf, p = find(node.split.after, block_id, path)
    if leaf then
      return leaf, p
    end
    path[#path] = nil
  end
  return nil
end

-- The pane among `candidates` that abuts `cur` in `dir` with the longest
-- shared border.
local function best_abutting(cur, candidates, dir)
  local best, best_len = nil, EPS
  local perp = other_axis(dir.axis)
  for _, leaf in ipairs(candidates) do
    if leaf.block_id ~= cur.block_id and abuts(cur.rect, leaf.rect, dir) then
      local len = overlap(cur.rect, leaf.rect, perp)
      if len > best_len then
        best, best_len = leaf, len
      end
    end
  end
  return best
end

-- Across the parent split, the sibling pane sharing the longest border with
-- `cur`, preferring the one furthest toward `dir` on a tie.
local function sibling_anchor(cur, parent, dir)
  local s = parent.split
  local in_before = find(s.before, cur.block_id) ~= nil
  local sibling = in_before and s.after or s.before
  local split_axis = s.direction == "horizontal" and "x" or "y"
  local toward = { axis = split_axis, sign = in_before and 1 or -1 }

  local best, best_len, best_pos = nil, EPS, nil
  local perp = other_axis(split_axis)
  for _, leaf in ipairs(leaves(sibling)) do
    if abuts(cur.rect, leaf.rect, toward) then
      local len = overlap(cur.rect, leaf.rect, perp)
      local lo, hi = span(leaf.rect, dir.axis)
      local pos = dir.sign * (lo + hi)
      if len > best_len + EPS or (math.abs(len - best_len) <= EPS and (best_pos == nil or pos > best_pos)) then
        best, best_len, best_pos = leaf, len, pos
      end
    end
  end
  return best
end

local function find_layer(view, block_id)
  for _, w in ipairs(view.windows or {}) do
    for _, layer in ipairs(w.layers or {}) do
      if layer.layout and find(layer.layout, block_id) then
        return layer
      end
    end
  end
end

rex.action({
  name = "move_pane",
  title = "Move Pane (re-split at edge)",
  category = "Panes",
  args = { direction = "string" },
  run = function(ctx, args)
    local dir = DIRS[args.direction]
    if not dir then
      error("direction must be left, right, up, or down", 0)
    end
    local block_id = ctx.block_id
    if not block_id then
      error("no focused pane", 0)
    end

    local view, err = rex.session.view({})
    if not view then
      error(err, 0)
    end
    local layer = find_layer(view, block_id)
    if not layer then
      return
    end

    local cur, path = find(layer.layout, block_id)
    local all = leaves(layer.layout)

    local neighbor = best_abutting(cur, all, dir)
    if neighbor then
      -- Let the app do the swap so it animates. Server-side layout calls
      -- (swap_blocks / move_block) just snap to the new layout.
      if ctx.client_id then
        rex.client.queue("pane.move", { direction = args.direction })
        return
      end
      local _, e = rex.session.swap_blocks({ block_id = block_id, other_block_id = neighbor.block_id })
      if e then
        error(e, 0)
      end
      return
    end

    local parent = path[#path]
    if not parent then
      return -- only pane in the layer
    end
    local anchor = sibling_anchor(cur, parent, dir)
    if not anchor then
      return
    end
    local _, e = rex.session.move_block({
      block_id = block_id,
      anchor_block_id = anchor.block_id,
      direction = dir.split,
      side = dir.side,
    })
    if e then
      error(e, 0)
    end
  end,
})

-- Pane focus that overflows into tabs.
--
-- focus_pane{ direction = "left" | "right" | "up" | "down" }
--   * Left/right with no pane on that side of the focused tiled pane switch to
--     the previous/next tab instead.
--   * Everything else (up/down, floats) is plain pane.focus.
rex.action({
  name = "focus_pane",
  title = "Focus Pane (tab at edge)",
  category = "Panes",
  args = { direction = "string" },
  run = function(ctx, args)
    local dir = DIRS[args.direction]
    if not dir then
      error("direction must be left, right, up, or down", 0)
    end
    if dir.axis == "x" and ctx.block_id then
      local view = rex.session.view({})
      local layer = view and find_layer(view, ctx.block_id)
      if layer and layer.kind == "tiled" then
        local cur = find(layer.layout, ctx.block_id)
        if not best_abutting(cur, leaves(layer.layout), dir) then
          rex.client.queue(dir.sign > 0 and "client.tab.next" or "client.tab.previous")
          return
        end
      end
    end
    rex.client.queue("pane.focus", { direction = args.direction })
  end,
})
