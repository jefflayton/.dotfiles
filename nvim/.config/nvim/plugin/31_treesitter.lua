local ts = require("nvim-treesitter")

local languages = {
	"bash",
	"c",
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
	"just",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"odin",
	"regex",
	"sql",
	"svelte",
	"typescript",
	"typst",
	"vim",
	"vimdoc",
	"yaml",
	"zig",
}

require("nvim-treesitter.parsers").just = {
	install_info = {
		url = "https://github.com/IndianBoy42/tree-sitter-just",
		files = { "src/parser.c", "src/scanner.c" },
		branch = "main",
		-- use_makefile = true -- this may be necessary on MacOS (try if you see compiler errors)
	},
	maintainers = { "@IndianBoy42" },
}

local not_installed = function(lang)
	return not pcall(vim.treesitter.language.inspect, lang)
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

require("nvim-ts-autotag").setup()
