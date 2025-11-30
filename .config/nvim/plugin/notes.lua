local deps = require("mini.deps")
local add, now, later = deps.add, deps.now, deps.later

now(function()
	add({ source = "preservim/vim-pencil" })
	vim.api.nvim_create_augroup("Pencil", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = "Pencil",
		pattern = { "text", "markdown", "typst" },
		callback = function()
			vim.cmd("PencilSoft")
		end,
	})
end)

later(function()
	add({ source = "chomosuke/typst-preview.nvim" })
	require("typst-preview").setup()

	add({ source = "OXY2DEV/markview.nvim" })
	require("markview").setup({
		experimental = { check_rtp = false },
		preview = { icon_provider = "mini" },
		latex = {
			enable = true,
		},
		typst = {
			enable = true,
		},
	})
	require("markview.extras.checkboxes").setup()
	vim.keymap.set("n", "<leader>ct", "<cmd>CheckboxToggle<cr>", { desc = "Markview: Toggle Checkbox" })

	add({ source = "epwalsh/obsidian.nvim", depends = { "nvim-lua/plenary.nvim" } })
	require("obsidian").setup({
		workspaces = {
			{
				name = "school",
				path = "~/Documents/vault/school",
			},
		},
	})
end)
