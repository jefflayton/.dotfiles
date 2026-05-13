local utils = require("utils")

local js_formatter = utils.tool_decider({
	{ paths = { "deno.json", "deno.jsonc" }, tools = { "deno_fmt" } },
	{
		paths = {
			".prettierrc",
			".prettierrc.json",
			".prettierrc.yml",
			".prettierrc.yaml",
			".prettierrc.json5",
			".prettierrc.js",
			".prettierrc.ts",
			".prettierrc.mjs",
			".prettierrc.cjs",
			".prettierrc.mts",
			".prettierrc.cts",
			".prettier.config.js",
			".prettier.config.ts",
			".prettier.config.mjs",
			".prettier.config.cjs",
			".prettier.config.mts",
			".prettier.config.cts",
			".prettierrc.toml",
		},
		tools = { "prettier" },
	},
})

local sql_formatter = { "sqlfluff" }

require("conform").setup({
	-- format_on_save = {
	-- 	timeout_ms = 500,
	-- 	lsp_format = "fallback",
	-- },
	format_on_save = function(bufnr)
		if vim.b[bufnr].disable_autoformat or vim.g.disable_autoformat then
			return
		end
		return { timeout_ms = 500, lsp_fallback = true }
	end,
	formatters_by_ft = {
		c = { "clang-format" },
		css = js_formatter,
		gdscript = { "gdscript-formatter" },
		html = js_formatter,
		java = { "google-java-format" },
		javascript = js_formatter,
		javascriptreact = js_formatter,
		json = js_formatter,
		jsonc = js_formatter,
		nix = { "nixfmt" },
		objc = { "clang-format" },
		odin = { "odinfmt" },
		lua = { "stylua" },
		roc = { "roc" },
		rust = { "rustfmt" },
		sql = sql_formatter,
		svelte = { "prettier" },
		toml = { "taplo" },
		typescript = js_formatter,
		typescriptreact = js_formatter,
		typst = { "typstyle" },
		yaml = js_formatter,
		zig = { "zigfmt" },
	},
	formatters = {
		["clang-format"] = {
			args = { "-assume-filename", "$FILENAME", "--style", "{BasedOnStyle: llvm, IndentWidth: 4}" },
		},
	},
})

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
