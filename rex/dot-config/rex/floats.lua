-- floats_toggle: minimize every visible float in the active window, or, when
--   none are visible, bring back the ones this toggle last hid. If it hid
--   none (they were minimized some other way), bring back only the top float.

local function active_window()
  local v = rex.session.view{}
  for _, w in ipairs(v.windows or {}) do
    if w.window_id == v.active_window_id then return w end
  end
end

local function floats(win)
  local out = {}
  for _, l in ipairs(win and win.layers or {}) do
    if l.kind ~= "tiled" then table.insert(out, l) end
  end
  return out
end

-- window_id -> layer_ids the last toggle minimized
local hidden = {}

rex.action{
  name  = "floats_toggle",
  title = "Toggle Floating Panes",
  run   = function(ctx, args)
    local win = active_window()
    if win == nil then return end
    local layers = floats(win)

    local visible = {}
    for _, l in ipairs(layers) do
      if l.state ~= "minimized" then table.insert(visible, l.layer_id) end
    end
    if #visible > 0 then
      for _, id in ipairs(visible) do
        rex.session.set_layer_state{ layer_id = id, state = "minimized" }
      end
      hidden[win.window_id] = visible
      return
    end

    -- Restore what we hid, if those layers still exist.
    local exists = {}
    for _, l in ipairs(layers) do exists[l.layer_id] = true end
    local restore = {}
    for _, id in ipairs(hidden[win.window_id] or {}) do
      if exists[id] then table.insert(restore, id) end
    end
    if #restore == 0 and #layers > 0 then
      restore = { layers[#layers].layer_id }
    end
    hidden[win.window_id] = nil
    for i, id in ipairs(restore) do
      rex.session.set_layer_state{ layer_id = id, state = "normal", focus = i == #restore }
    end
  end,
}

rex.bind("cmd+shift+m", "floats_toggle")
