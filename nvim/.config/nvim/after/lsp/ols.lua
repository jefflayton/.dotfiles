---@brief
---
--- https://github.com/DanielGavin/ols
---
--- `Odin Language Server`.

local utils = require("utils")

---@type vim.lsp.Config
return {
	cmd = { "ols" },
	filetypes = { "odin" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		on_dir(utils.root_pattern("ols.json", ".git", "*.odin")(fname))
	end,
}
