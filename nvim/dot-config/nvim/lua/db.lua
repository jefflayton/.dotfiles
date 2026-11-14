-- URL helpers for dadbod-ui connections in a project's .nvim.lua:
--
--   local db = require("db")
--   vim.g.dbs = {
--     { name = "local", url = "postgresql://postgres:postgres@127.0.0.1:54322/postgres" },
--     { name = "preview", url = db.env(".env.preview") },                     -- plain or dotenvx-encrypted
--     { name = "prod", url = db.env(".env.prod", "SUPABASE_DB_URL") },        -- another variable
--     { name = "custom", url = db.cmd({ "op", "read", "op://dev/db/url" }) }, -- any command's stdout
--   }
--
-- Each helper returns a function, so nothing is read, run or decrypted until :DBUI opens.
local M = {}

-- An empty URL stops the whole drawer from opening, so failures return a URL that parses
-- but can't connect (.invalid is a reserved TLD).
local function failed(what, err)
	vim.notify(("dadbod: %s failed\n%s"):format(what, err or ""), vim.log.levels.WARN)
	return "postgresql://failed.invalid/" .. (what:gsub("[^%w._-]", "_"))
end

-- Relative paths resolve against the .nvim.lua's directory, not wherever nvim's cwd is later.
local function project_path(file)
	if vim.startswith(file, "/") or vim.startswith(file, "~") then
		return vim.fn.expand(file)
	end
	local config = require("local_config").lookup()
	return vim.fs.joinpath(config and vim.fs.dirname(config) or vim.fn.getcwd(), file)
end

--- Use a command's trimmed stdout as the URL.
---@param argv string[]
---@param opts? vim.SystemOpts e.g. { cwd = ... }
function M.cmd(argv, opts)
	return function()
		local ok, res = pcall(function()
			return vim.system(argv, vim.tbl_extend("force", { text = true }, opts or {})):wait()
		end)
		local url = ok and vim.trim(res.stdout or "") or ""
		if not ok or res.code ~= 0 or url == "" then
			return failed(argv[1], table.concat(argv, " ") .. "\n" .. (ok and res.stderr or res))
		end
		return url
	end
end

--- Read `key` (default DATABASE_URL) from an env file, decrypting dotenvx `encrypted:` values.
---@param file string relative to the project's .nvim.lua, or absolute
---@param key? string
function M.env(file, key)
	key = key or "DATABASE_URL"
	local path = project_path(file)
	return function()
		if vim.fn.filereadable(path) == 0 then
			return failed(file, "file not found: " .. path)
		end
		local value = vim.fn.DotenvRead(path)[key]
		if value == nil or value == "" then
			return failed(file, key .. " not set")
		end
		if vim.startswith(value, "encrypted:") then
			-- dotenvx finds .env.keys next to the file; DOTENV_PRIVATE_KEY_* env vars also work.
			return M.cmd({ "dotenvx", "get", key, "-f", path }, { cwd = vim.fs.dirname(path) })()
		end
		return value
	end
end

return M
