local deps = require("mini.deps")
local add, now, later = deps.add, deps.now, deps.later

now(function()
	add({ source = "sindrets/diffview.nvim" })
	vim.keymap.set("n", "<C-D>o", "<cmd>DiffviewOpen<cr>", { desc = "Git: Open Diffview" })
	vim.keymap.set("n", "<C-D>c", "<cmd>DiffviewClose<cr>", { desc = "Git: Close Diffview" })
end)

later(function()
	add({ source = "lewis6991/gitsigns.nvim" })
	require("gitsigns").setup({ current_line_blame = true })

	add({
		source = "NeogitOrg/neogit",
		depends = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
			"echasnovski/mini.pick",
		},
	})
end)
