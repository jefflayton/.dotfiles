vim.g["pencil#conceallevel"] = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
	end,
})

require("markview").setup({
	experimental = { check_rtp = false },
	preview = { enable = false, enable_hybrid_mode = false, icon_provider = "mini" },
	markdown = { enable = true },
	typst = { enable = true },
})
require("markview.extras.checkboxes").setup()
vim.keymap.set("n", "<leader>ct", "<cmd>CheckboxToggle<cr>", { desc = "Markview: Toggle Checkbox" })
