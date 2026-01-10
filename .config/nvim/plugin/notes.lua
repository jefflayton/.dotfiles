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
		preview = { icon_provider = "mini" },
		typst = { enable = false },
	})

	require("markview.extras.checkboxes").setup()
	vim.keymap.set("n", "<c-m>c", "<cmd>Checkbox toggle<cr>", { desc = "Markview: Toggle Checkbox" })
end)
