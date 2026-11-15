require("keys")
require("move")
require("files")
require("floats")

-- Machine-only settings in local.lua (gitignored); a missing file is fine.
local ok, err = pcall(require, "local")
if not ok and not tostring(err):find("module 'local' not found", 1, true) then error(err) end
