require("keys")
require("move")
require("files")
require("floats")
require("prs")
require("open")

-- Machine-only settings in local.lua (gitignored); a missing file is fine.
local ok, err = pcall(require, "local")
if not ok and not tostring(err):find("module '?local'? not found") then error(err) end
