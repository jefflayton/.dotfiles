vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
		vim.keymap.set("n", "<leader>ct", "<cmd>Checkbox toggle<cr>", { desc = "Markview: Toggle Checkbox" })
	end,
})

require("orgmode").setup({
	org_agenda_files = "~/Documents/notes",
})
vim.schedule(function()
	vim.lsp.enable("org")
end)
