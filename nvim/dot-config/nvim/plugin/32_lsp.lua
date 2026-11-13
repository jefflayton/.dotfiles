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
			fzf.diagnostics_document()
		end, "Buffer Diagnostics")

		-- Inline type/parameter hints
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
			nmap("grh", function()
				local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf })
				vim.lsp.inlay_hint.enable(not enabled, { bufnr = args.buf })
			end, "Toggle Inlay Hints")
		end
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
	"bicep",
	"clangd",
	"denols",
	"harperls",
	"luals",
	"postgres_lsp",
	"jdtls",
	"jsonls",
	"ocamllsp",
	"ols",
	"oxlint",
	"rust_analyzer",
	"sqls",
	"sourcekit",
	"svelte",
	"tailwindcss",
	"tinymist",
	"tombi",
	"tsgo",
	"yamlls",
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
