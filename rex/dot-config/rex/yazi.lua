-- Yazi for Rex (macOS). Needs yazi on PATH.
-- Install: copy this file to ~/.config/rex/yazi.lua, add require("yazi")
-- to ~/.config/rex/init.lua, then choose Reload Config in Rex.
-- cmd+e opens yazi in a floating pane, hides it, or brings it back.
-- Quitting with q cds the pane yazi was opened from to yazi's last directory.

-- Yazi in a floating pane, opened at the focused terminal's working directory.
local function focused_dir(ctx)
  if ctx.block_id == nil then return nil end
  local ok, r = pcall(rex.block.call, "com.superlogical.terminal", "pwd", { block_id = ctx.block_id })
  if not ok or type(r) ~= "table" or r.pwd == nil then return nil end
  -- OSC 7 reports file://host/path with percent-encoding.
  local path = r.pwd:gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local terminal = "com.superlogical.terminal"
local rex_bin = os.getenv("HOME") .. "/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex"
local shells = { zsh = true, bash = true, fish = true, sh = true }

local function sh_quote(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

-- Find the floating layer holding the yazi pane in the active window.
local function yazi_layer()
  local v = rex.session.view{}
  for _, w in ipairs(v.windows or {}) do
    if w.window_id == v.active_window_id then
      for _, l in ipairs(w.layers or {}) do
        for _, b in ipairs(l.blocks or {}) do
          if b.label == "yazi" and l.kind ~= "tiled" then return l, b, w end
        end
      end
    end
  end
end

-- cmd+e toggles one yazi per window: open it, hide it, or bring it back.
rex.action{
  name  = "yazi",
  title = "Toggle Yazi",
  run   = function(ctx, args)
    local layer, block, win = yazi_layer()
    if layer ~= nil then
      if layer.state ~= "minimized" and win.focused_block_id == block.block_id then
        rex.session.set_layer_state{ layer_id = layer.layer_id, state = "minimized" }
      else
        rex.session.set_layer_state{ layer_id = layer.layer_id, state = "normal", focus = true }
      end
      return
    end
    -- After yazi quits with q, yazi_cd moves the original pane's shell to yazi's last directory.
    local script = 'f=$(mktemp -t yazi-cwd); yazi --cwd-file="$f"; '
      .. sh_quote(rex_bin) .. ' do yazi_cd -s ' .. ctx.session_id
      .. ' block=' .. (ctx.block_id or "") .. ' file="$f"; rm -f "$f"'
    local node = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { command = { "/bin/sh", "-c", script }, cwd = focused_dir(ctx) },
    }
    node.block.label = "yazi"
    local _, err = rex.session.new_layer{ bounds = { 0.1, 0.1, 0.8, 0.8 }, focus = true, layout = node }
    if err ~= nil then error(err, 0) end
  end,
}

rex.action{
  name  = "yazi_cd",
  title = "Yazi: cd Pane to Last Directory",
  args  = { block = "string", file = "string" },
  run   = function(ctx, args)
    local f = io.open(args.file, "r")
    if f == nil then return end
    local dir = f:read("*a")
    f:close()
    if dir == "" or args.block == "" then return end
    local ok, p = pcall(rex.block.call, terminal, "process", { block_id = args.block })
    -- Only type into a shell sitting at its prompt, never into a running program.
    if not ok or p.foreground == nil or p.child == nil then return end
    -- On macOS the pane's child is login, which runs the shell.
    local top = p.foreground.pid == p.child.pid or p.child.name == "login"
    if not top or not shells[p.foreground.name] then return end
    if p.foreground.cwd == dir then return end
    rex.block.call(terminal, "write", { block_id = args.block, data = "cd -- " .. sh_quote(dir) .. "\r" })
  end,
}

rex.bind("cmd+e", "yazi")
