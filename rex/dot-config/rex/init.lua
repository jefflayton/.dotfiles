require("keys")
require("move")
require("files")
require("floats")
require("prs")
require("open")
-- Machine-only files in local/ (gitignored): every *.lua there loads, in name order.
local dir = os.getenv("HOME") .. "/.config/rex/local"
local r = rex.exec({ "find", dir, "-maxdepth", "1", "-name", "*.lua" })
if r and r.ok then
  local names = {}
  for path in r.stdout:gmatch("[^\n]+") do table.insert(names, path:match("([^/]+)%.lua$")) end
  table.sort(names)
  for _, name in ipairs(names) do require("local." .. name) end
end
