local add, now = require("mini.deps").add, require("mini.deps").now

now(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		checkout = "main",
		hooks = {
			post_checkout = function()
				vim.cmd("TSUpdate")
			end,
		},
	})
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
		"vim",
		"yaml",
		"zig",
	})

	-- Enable treesitter highlighting
	local augroup = vim.api.nvim_create_augroup("my.treesitter", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = augroup,
		pattern = { "*" },
		callback = function(event)
			local filetype = event.match
			local lang = vim.treesitter.language.get_lang(filetype)
			local is_installed, error
			if lang then
				is_installed, error = vim.treesitter.language.add(lang)
			end

			if not is_installed then
				local available_langs = ts.get_available()
				local is_available = vim.tbl_contains(available_langs, lang)

				if is_available then
					vim.notify("Installing treesitter parser for " .. lang, vim.log.levels.INFO)
					ts.install({ lang }):wait(30 * 1000)
				end
			end

			local ok, _ = pcall(vim.treesitter.start, event.buf, lang)
			if not ok then
				return
			end

			vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end,
	})
end)
