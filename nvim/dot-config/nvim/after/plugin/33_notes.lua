vim.g["pencil#conceallevel"] = 0

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
	end,
})

require("markview").setup({
	preview = {
		icon_provider = "internal", -- "mini" or "devicons"
	},
})
