local fzf = require("fzf-lua")

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local nmap = function(keys, func, desc)
			vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
		end

		nmap("grd", function()
			fzf.lsp_definitions()
		end, "Goto Definition")
		nmap("grr", function()
			fzf.lsp_references()
		end, "Goto References")
		nmap("gri", function()
			fzf.lsp_implementations()
		end, "Goto Implementation")
		nmap("grt", function()
			fzf.lsp_typedefs()
		end, "Type Definition")
		nmap("grs", function()
			fzf.lsp_document_symbols()
		end, "Document Symbols")
		nmap("grw", function()
			fzf.lsp_live_workspace_symbols()
		end, "Workspace Symbols")
		nmap("grf", function()
			fzf.diagnostics_workspace()
		end, "Workspace Diagnostics")
		nmap("grD", function()
			fzf.diagnostics_buffer()
		end, "Diagnostics")
	end,
})

vim.lsp.config("*", {
	handlers = {
		["$/progress"] = function(_, result)
			local val = result.value
			if val.kind == "end" then
				vim.api.nvim_ui_send("\027]9;4;0;\027\\")
			else
				vim.api.nvim_ui_send("\027]9;4;3;\027\\")
			end
		end,
	},
})

vim.lsp.enable({
	"basedpyright",
	"clangd",
	"denols",
	"harperls",
	"luals",
	"postgres_lsp",
	"jdtls",
	"jsonls",
	"ols",
	"rust_analyzer",
	"sqls",
	"sourcekit",
	"svelte",
	"tailwindcss",
	"tinymist",
	"tsgo",
	"zls",
})

local ts_servers = { "tsgo", "denols" }
local function format_ts_diagnostic(diagnostic)
	if diagnostic.message and vim.fn.exists("*PrettyTsFormat") == 1 then
		local formatted = vim.fn.PrettyTsFormat(diagnostic.message)
		if formatted and formatted ~= "" then
			diagnostic.message = formatted
		end
	end
	return diagnostic
end

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
