-- rex_open: open files in nvim in a new tab of a session picked in the palette.
-- Run by rex-open.sh ("Rex Open.app"). Type a name that matches no session to create one.

rex.action{
  name  = "rex_open",
  title = "Open Files in Session",
  args  = { files = "array", cwd = "string" },
  run   = function(ctx, args)
    local tab = args.files[1]:gsub("/$", ""):match("[^/]+$")
    local default = args.cwd:match("[^/]+$") or "home"

    local items = {}
    for _, s in ipairs(rex.call("session.list").sessions or {}) do
      table.insert(items, { id = s.session_id, title = s.label, icon = "terminal" })
    end
    table.insert(items, { id = "new", title = "New session: " .. default, icon = "plus" })

    local choice, reason, detail = rex.ui.pick{
      title = "Open " .. tab .. " in",
      placeholder = "Session, or a name for a new one",
      items = items,
      allow_other = true,
    }
    if choice == nil then
      if reason == "cancelled" or reason == "timeout" then return end
      error(detail or reason, 0)
    end

    local command = { "nvim", "--" }
    for _, f in ipairs(args.files) do table.insert(command, f) end
    local layout = rex.layout.block{
      flavor  = "com.superlogical.terminal.shell",
      options = { command = command, cwd = args.cwd },
    }
    local sid, wid, err
    if type(choice) == "table" or choice == "new" then
      local name = type(choice) == "table" and choice.text or default
      local r
      r, err = rex.call("session.create", { label = name, initial_windows = { { window_label = tab, layout = layout } } })
      if r then sid, wid = r.session_id, r.initial_windows[1].window_id end
    else
      -- an action can only act on sessions its stream is attached to
      local r
      r, err = rex.call("session.attach", { session_id = choice })
      if r then r, err = rex.session.new_window{ session_id = choice, window_label = tab, layout = layout } end
      if r then sid, wid = choice, r.window_id end
    end
    if err ~= nil then error(err, 0) end
    rex.client.queue("session.select", { session_id = sid, window_id = wid })
  end,
}
