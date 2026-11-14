-- File explorer for Rex (macOS): nvim + mini.files in a floating pane.
-- cmd+e opens it at the focused terminal's working directory, hides it, or brings it back.
-- g~ in mini.files cds the pane it was opened from (see nvim plugin/41_files.lua).

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

-- Find the floating layer holding the files pane in the active window.
local function files_layer()
  local v = rex.session.view{}
  for _, w in ipairs(v.windows or {}) do
    if w.window_id == v.active_window_id then
      for _, l in ipairs(w.layers or {}) do
        for _, b in ipairs(l.blocks or {}) do
          if b.label == "files" and l.kind ~= "tiled" then return l, b, w end
        end
      end
    end
  end
end

-- cmd+e toggles one explorer per window: open it, hide it, or bring it back.
rex.action{
  name  = "files",
  title = "Toggle Files",
  run   = function(ctx, args)
    local layer, block, win = files_layer()
    if layer ~= nil then
      if layer.state ~= "minimized" and win.focused_block_id == block.block_id then
        rex.session.set_layer_state{ layer_id = layer.layer_id, state = "minimized" }
      else
        rex.session.set_layer_state{ layer_id = layer.layer_id, state = "normal", focus = true }
      end
      return
    end
    -- nvim reads REX_* to run cd_pane on the origin pane when you press g~,
    -- and writes its cwd to NVIM_CWD_FILE on exit so the origin pane follows it.
    local block = sh_quote(ctx.block_id or "")
    local script = 'f=$(mktemp -t nvim-cwd); '
      .. "REX_ORIGIN_BLOCK=" .. block .. " REX_BIN=" .. sh_quote(rex_bin)
      .. ' NVIM_CWD_FILE="$f" nvim \'+lua MiniFiles.open()\'; '
      .. sh_quote(rex_bin) .. " do cd_pane -s " .. ctx.session_id
      .. " block=" .. block .. ' dir="$(cat "$f")"; rm -f "$f"'
    local node = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { command = { "/bin/sh", "-c", script }, cwd = focused_dir(ctx) },
    }
    node.block.label = "files"
    local _, err = rex.session.new_layer{ bounds = { 0.1, 0.1, 0.8, 0.8 }, focus = true, layout = node }
    if err ~= nil then error(err, 0) end
  end,
}

rex.action{
  name  = "cd_pane",
  title = "cd Pane to Directory",
  args  = { block = "string", dir = "string" },
  run   = function(ctx, args)
    if args.dir == "" or args.block == "" then return end
    local ok, p = pcall(rex.block.call, terminal, "process", { block_id = args.block })
    -- Only type into a shell sitting at its prompt, never into a running program.
    if not ok or p.foreground == nil or p.child == nil then return end
    -- On macOS the pane's child is login, which runs the shell.
    local top = p.foreground.pid == p.child.pid or p.child.name == "login"
    if not top or not shells[p.foreground.name] then return end
    if p.foreground.cwd == args.dir then return end
    rex.block.call(terminal, "write", { block_id = args.block, data = "cd -- " .. sh_quote(args.dir) .. "\r" })
  end,
}

rex.bind("cmd+e", "files")
