-- Per-project dadbod-ui: connections come from the project's .nvim.lua (vim.g.dbs, see lua/db.lua),
-- and connections added in the UI plus saved queries are stored per project.
-- A plain .env DATABASE_URL / DB_UI_* still comes from dadbod-ui's own dotenv support.
local local_config = require("local_config")

-- Project = the .nvim.lua's directory, else the repo root, else cwd. Returns true if it changed.
local function set_project()
	local config = local_config.lookup()
	local cwd = vim.fn.getcwd()
	local root = config and vim.fs.dirname(config) or vim.fs.root(cwd, { ".git", ".jj" }) or cwd
	local location = vim.fn.stdpath("data") .. "/db_ui/" .. root:gsub("/", "%%")
	local changed = vim.g.db_ui_save_location ~= location
	vim.g.db_ui_save_location = location
	return changed
end

-- init.lua already sourced this project's .nvim.lua.
set_project()

vim.api.nvim_create_autocmd("DirChanged", {
	callback = function()
		if not set_project() then
			return
		end
		vim.g.dbs = nil
		local_config.source()
		-- Close and drop the old project's drawer so the next :DBUI shows this project only.
		-- (These functions exist only once dadbod-ui has been opened.)
		if vim.fn.exists("*db_ui#reset_state") == 1 then
			vim.fn["db_ui#close"]()
			vim.fn["db_ui#reset_state"]()
		end
	end,
})
