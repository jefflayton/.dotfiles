vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
	end,
})

require("orgmode").setup({
	org_agenda_files = "~/Documents/notes",
})
vim.schedule(function()
	vim.lsp.enable("org")
end)
