require("markview").setup({
	preview = { icon_provider = "mini" },
	typst = {
		code_blocks = { enable = false },
		code_spans = { enable = false },
	},
})
require("markview.extras.checkboxes").setup()

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
		vim.keymap.set("n", "<leader>ct", "<cmd>Checkbox toggle<cr>", { desc = "Markview: Toggle Checkbox" })
	end,
})

require("orgmode").setup({
	org_agenda_files = "~/notes",
})
vim.schedule(function()
	vim.lsp.enable("org")
end)
