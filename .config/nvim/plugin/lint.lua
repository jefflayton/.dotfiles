local add, later = require("mini.deps").add, require("mini.deps").later
local utils = require("utils")

later(function()
	local js_linter = utils.tool_decider({
		{ paths = { "deno.json", "deno.jsonc" }, tools = { "deno" } },
		{
			paths = {
				".eslintrc",
				".eslintrc.js",
				".eslintrc.cjs",
				".eslintrc.yaml",
				".eslintrc.yml",
				".eslintrc.json",
				"eslint.config.js",
				"eslint.config.mjs",
				"eslint.config.cjs",
				"eslint.config.ts",
				"eslint.config.mts",
				"eslint.config.cts",
			},
			tools = { "eslint_d" },
		},
		{ paths = { "biome.json", "biome.jsonc" }, tools = { "biomejs" } },
	})

	vim.env.ESLINT_D_PPID = vim.fn.getpid()

	add({ source = "mfussenegger/nvim-lint" })
	local lint = require("lint")
	lint.linters_by_ft = {
		c = { "clangtidy" },
		javascript = js_linter,
		json = { "jsonlint" },
		jsonc = { "jsonlint" },
		typescript = js_linter,
	}

	vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufReadPost" }, {
		callback = function()
			lint.try_lint()
		end,
	})
end)
