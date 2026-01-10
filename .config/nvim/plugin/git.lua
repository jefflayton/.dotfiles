local deps = require("mini.deps")
local add, later = deps.add, deps.later

later(function()
	add({ source = "lewis6991/gitsigns.nvim" })
	require("gitsigns").setup({ current_line_blame = true })
end)
