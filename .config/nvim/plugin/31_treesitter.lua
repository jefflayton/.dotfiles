local ts = require("nvim-treesitter")

local languages = {
	"bash",
	"c",
	"comment",
	"cpp",
	"css",
	"dockerfile",
	"fish",
	"html",
	"http",
	"java",
	"javascript",
	"jsdoc",
	"json",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"nu",
	"regex",
	"roc",
	"sql",
	"svelte",
	"typescript",
	"typst",
	"vim",
	"vimdoc",
	"yaml",
	"zig",
}

local not_installed = function(lang)
	return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
end

local to_install = vim.tbl_filter(not_installed, languages)
if #to_install > 0 then
	ts.install(to_install)
end

local filetypes = {}
for _, lang in ipairs(languages) do
	for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
		table.insert(filetypes, ft)
	end
end
local ts_start = function(ev)
	vim.treesitter.start(ev.buf)
end
vim.api.nvim_create_autocmd("FileType", {
	pattern = filetypes,
	callback = ts_start,
})
