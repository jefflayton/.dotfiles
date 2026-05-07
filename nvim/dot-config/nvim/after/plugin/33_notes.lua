vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
	end,
})
