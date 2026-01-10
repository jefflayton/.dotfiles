local add, later = require("mini.deps").add, require("mini.deps").later
local utils = require("utils")

later(function()
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
		{ paths = { "biome.json", "biome.jsonc" }, tools = { "biome" } },
	})

	local sql_formatter = utils.tool_decider({
		{ paths = { ".pg_format" }, tools = { "pg_format" } },
		{ tools = { "sqlfluff" } },
	})

	add({ source = "stevearc/conform.nvim" })
	local conform = require("conform")
	conform.setup({
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
		formatters_by_ft = {
			c = { "clang-format" },
			css = js_formatter,
			html = js_formatter,
			javascript = js_formatter,
			javascriptreact = js_formatter,
			json = js_formatter,
			jsonc = js_formatter,
			lua = { "stylua" },
			roc = { "roc" },
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
end)
