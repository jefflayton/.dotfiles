-- My open PRs across all repos: nvim + octo.nvim in a floating pane.
-- cmd+shift+o opens it, or focuses it if already open (hide with cmd+shift+m).

local function prs_layer()
  local v = rex.session.view{}
  for _, w in ipairs(v.windows or {}) do
    if w.window_id == v.active_window_id then
      for _, l in ipairs(w.layers or {}) do
        for _, b in ipairs(l.blocks or {}) do
          if b.label == "prs" and l.kind ~= "tiled" then return l end
        end
      end
    end
  end
end

rex.action{
  name  = "prs",
  title = "My Pull Requests",
  run   = function(ctx, args)
    local layer = prs_layer()
    if layer ~= nil then
      rex.session.set_layer_state{ layer_id = layer.layer_id, state = "normal", focus = true }
      return
    end
    local node = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { command = { "/bin/sh", "-c", "nvim '+Octo search is:pr is:open author:@me'" } },
    }
    node.block.label = "prs"
    local _, err = rex.session.new_layer{ bounds = { 0.05, 0.05, 0.9, 0.9 }, focus = true, layout = node }
    if err ~= nil then error(err, 0) end
  end,
}

rex.bind("cmd+shift+o", "prs")
