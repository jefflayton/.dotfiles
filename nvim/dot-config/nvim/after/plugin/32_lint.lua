local utils = require("utils")

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
})

vim.env.ESLINT_D_PPID = vim.fn.getpid()

local lint = require("lint")
lint.linters_by_ft = {
	c = { "clangtidy" },
	javascript = js_linter,
	json = { "jsonlint" },
	jsonc = { "jsonlint" },
	sql = { "sqruff" },
	typescript = js_linter,
}

local deno = lint.linters.deno
deno.args = {
	"lint",
	"--json",
}

vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufReadPost" }, {
	callback = function()
		lint.try_lint()
	end,
})
