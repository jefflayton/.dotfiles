local add, now = require("mini.deps").add, require("mini.deps").now

now(function()
	add({ source = "nvim-treesitter/nvim-treesitter", checkout = "main", monitor = "main" })
	local ts = require("nvim-treesitter")
	ts.setup({
		sync_install = true,
		auto_install = true,
		ignore_install = {},
		highlight = {
			enable = true,
			disable = {},
			additional_vim_regex_highlighting = true,
		},
		indent = { enable = true },
		autotag = {
			enable = false,
		},
		refactor = {
			highlight_definitions = {
				enable = false,
			},
			highlight_current_scopes = {
				enable = false,
			},
			smart_rename = {
				enable = true,
			},
		},
	})

	ts.install({
		"bash",
		"c",
		"cpp",
		"css",
		"csv",
		"dockerfile",
		"fish",
		"html",
		"http",
		"java",
		"javascript",
		"jsdoc",
		"json",
		"jsonc",
		"lua",
		"make",
		"markdown",
		"markdown_inline",
		"regex",
		"sql",
		"svelte",
		"typescript",
		"typst",
		"yaml",
		"zig",
	})
end)
