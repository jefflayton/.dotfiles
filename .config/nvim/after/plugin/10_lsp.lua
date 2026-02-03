local extra = require("mini.extra")

vim.api.nvim_create_user_command("LspInfo", function()
	vim.cmd("checkhealth vim.lsp")
end, {
	desc = "Run checkhealth for vim.lsp",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.bo[args.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

		local nmap = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
		end

		nmap("grd", function()
			extra.pickers.lsp({ scope = "definition" })
		end, "Goto Definition")
		nmap("grr", function()
			extra.pickers.lsp({ scope = "references" })
		end, "Goto References")
		nmap("gri", function()
			extra.pickers.lsp({ scope = "implementation" })
		end, "Goto Implementation")
		nmap("grt", function()
			extra.pickers.lsp({ scope = "type_definition" })
		end, "Type Definition")
		nmap("grs", function()
			extra.pickers.lsp({ scope = "document_symbol" })
		end, "Document Symbols")
		nmap("grw", function()
			extra.pickers.lsp({ scope = "workspace_symbol" })
		end, "Workspace Symbols")
		nmap("grf", function()
			extra.pickers.diagnostic({
				scope = "all",
			})
		end, "All Diagnostics")
		nmap("grD", function()
			extra.pickers.diagnostic({
				scope = "current",
			})
		end, "Diagnostics")
	end,
})

vim.schedule(function()
	vim.lsp.enable({
		"denols",
		"harperls",
		"luals",
		"postgres_lsp",
		"jdtls",
		"jsonls",
		"sqls",
		"svelte",
		"tailwindcss",
		"tinymist",
		"ts_ls",
		"zls",
	})

	local ts_servers = { "ts_ls", "denols" }
	local function format_ts_diagnostic(diagnostic)
		if diagnostic.message and vim.fn.exists("*PrettyTsFormat") == 1 then
			local formatted = vim.fn.PrettyTsFormat(diagnostic.message)
			if formatted and formatted ~= "" then
				diagnostic.message = formatted
			end
		end
		return diagnostic
	end

	for _, server in ipairs(ts_servers) do
		local handler = vim.lsp.handlers["textDocument/publishDiagnostics"]

		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			local client = vim.lsp.get_client_by_id(ctx.client_id)

			if client and vim.tbl_contains(ts_servers, client.name) then
				if result and result.diagnostics then
					for _, diagnostic in ipairs(result.diagnostics) do
						format_ts_diagnostic(diagnostic)
					end
				end
			end
			return handler(err, result, ctx, config)
		end
	end
end)
