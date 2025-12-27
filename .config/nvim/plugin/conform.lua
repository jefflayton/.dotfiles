local add, later = require("mini.deps").add, require("mini.deps").later
local utils = require("utils")

later(function()
	add({
		source = "stevearc/conform.nvim",
	})
	local conform = require("conform")

	local js_formatter = utils.deno_or_node({ "deno_fmt" }, { "prettier" })

	local sql_formatter = function()
		local pg_wd = utils.root_pattern({ ".pg_format" })

		if pg_wd ~= nil then
			return {}
		else
			return { "pg_format" }
		end
	end

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
			sql = sql_formatter(),
			svelte = { "prettier" },
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
