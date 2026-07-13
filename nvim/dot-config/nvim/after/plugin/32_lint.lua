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

local sql_linter = utils.tool_decider({
	{ paths = { "postgres-language-server.jsonc" }, tools = { "postgres-language-server" } },
	{ tools = { "sqlfluff" } },
})

vim.env.ESLINT_D_PPID = vim.fn.getpid()

local lint = require("lint")
lint.linters_by_ft = {
	c = { "clangtidy" },
	javascript = js_linter,
	json = { "jsonlint" },
	jsonc = { "jsonlint" },
	sql = sql_linter,
	typescript = js_linter,
}

local deno = lint.linters.deno
deno.args = {
	"lint",
	"--json",
}

local severity_map = {
	error = vim.diagnostic.severity.ERROR,
	warning = vim.diagnostic.severity.WARN,
	information = vim.diagnostic.severity.INFO,
	info = vim.diagnostic.severity.INFO,
	hint = vim.diagnostic.severity.HINT,
}

lint.linters["postgres-language-server"] = {
	cmd = "postgres-language-server",
	args = { "check", "--reporter=json" },
	stdin = false,
	ignore_exitcode = true,
	stream = "stdout",
	parser = function(output)
		local diagnostics = {}
		local decoded
		for _, line in ipairs(vim.split(output, "\n", { trimempty = true })) do
			if line:sub(1, 1) == "{" then
				local ok, result = pcall(vim.json.decode, line)
				if ok then
					decoded = result
					break
				end
			end
		end
		for _, d in ipairs(decoded and decoded.diagnostics or {}) do
			local loc = d.location or {}
			local start = loc.start or {}
			local finish = loc["end"] or {}
			table.insert(diagnostics, {
				source = "postgres-language-server",
				lnum = math.max((start.line or 1) - 1, 0),
				col = math.max((start.column or 1) - 1, 0),
				end_lnum = finish.line and finish.line - 1 or nil,
				end_col = finish.column and finish.column - 1 or nil,
				severity = severity_map[d.severity] or vim.diagnostic.severity.WARN,
				message = d.message,
				code = d.category,
			})
		end
		return diagnostics
	end,
}

vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost", "BufReadPost" }, {
	callback = function()
		lint.try_lint()
	end,
})
