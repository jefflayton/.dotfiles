local deps = require("mini.deps")
local add, now, later = deps.add, deps.now, deps.later

now(function()
	add({
		source = "esmuellert/vscode-diff.nvim",
		depends = { "MunifTanjim/nui.nvim" },
		checkout = "next",
	})
	require("vscode-diff").setup({})

	vim.keymap.set("n", "<C-D>o", "<cmd>CodeDiff<cr>", { desc = "Git: Open Diff" })
end)

later(function()
	add({ source = "lewis6991/gitsigns.nvim" })
	require("gitsigns").setup({ current_line_blame = true })
end)
