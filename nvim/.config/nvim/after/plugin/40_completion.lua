require("mini.snippets").setup()

vim.o.completeopt = "menuone,noinsert,fuzzy,nosort"
require("mini.completion").setup({
	delay = { completion = 0, info = 1500, signature = 200 },
	lsp_completion = {
		source_func = "omnifunc",
		auto_setup = false,
	},
})

local map_multistep = require("mini.keymap").map_multistep
map_multistep("i", "<Tab>", { "pmenu_accept" })
map_multistep("i", "<C-n>", { "pmenu_next" })
map_multistep("i", "<C-p>", { "pmenu_prev" })

local pmenu_dismiss = {
	condition = function()
		return vim.fn.pumvisible() == 1
	end,
	action = function()
		return "<C-e><CR>"
	end,
}
map_multistep("i", "<CR>", { pmenu_dismiss, "minipairs_cr" })

require("mini.cmdline").setup()

-- Dadbod completion for SQL
-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = { "sql", "mysql", "plsql" },
-- 	callback = function()
-- 		vim.bo.omnifunc = "vim_dadbod_completion#omni"
-- 	end,
-- })
