vim.g.mapleader = " "
vim.g.maplocalleader = ";"

-- Formatting
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.scrolloff = 8

vim.o.swapfile = false

vim.o.mouse = "a"

-- Sync clipboard with MacOS
vim.o.clipboard = "unnamedplus"

-- Case insensitive searching
vim.o.ignorecase = true
vim.o.hlsearch = false
vim.o.smartcase = true

-- Terminal Colors
vim.o.termguicolors = true

vim.o.conceallevel = 0

-- For Deno
vim.g.markdown_fenced_languages = {
	"ts=typescript",
}

-- Diable auto comment on newlines after a comment
vim.o.formatoptions = "rqnl1j"
-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

vim.o.spelloptions = "camel"

vim.diagnostic.config({
	-- Show signs on top of any other sign, but only for warnings and errors
	signs = { priority = 9999, severity = { min = "WARN", max = "ERROR" } },

	-- Show all diagnostics as underline
	underline = { severity = { min = "HINT", max = "ERROR" } },

	virtual_lines = false,
	virtual_text = {
		current_line = true,
		severity = { min = "ERROR", max = "ERROR" },
	},

	update_in_insert = false,

	float = { border = "single" },
})

require("vim._core.ui2").enable({
	enable = true,
	msg = {
		---@type 'cmd'|'msg' Where to place regular messages, either in the
		---cmdline or in a separate ephemeral message window.
		target = "cmd",
		timeout = 4000,
	},
})
