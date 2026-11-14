-- Thanks https://schilk.co/blog/nvim-local-conf/

--- local_config.lua
local M = {}

M.CONFIG_FILE_NAMES = { ".nvim.lua" }

--- Look for local config file, searching up from the cwd
--- (not findfile's ".", which is the current buffer's directory)
function M.lookup()
	return vim.fs.find(M.CONFIG_FILE_NAMES, { upward = true, path = vim.fn.getcwd() })[1]
end

--- Find & load local config file
function M.source()
	local file = M.lookup()
	if not file or file == "" then
		return
	end

	local content = vim.secure.read(file) --[[@as string|nil]]
	if not content then
		vim.notify("[local_config]: local config file found but not trusted!", vim.log.levels.WARN)
		return
	end

	local config_fn, err_load = loadstring(content, "@" .. file)
	if not config_fn then
		vim.notify("[local_config]: failed to load local config file: " .. err_load, vim.log.levels.ERROR)
		return
	end

	local success, err_call = pcall(config_fn)
	if not success then
		vim.notify("[local_config]: failed to load local config file: " .. err_call, vim.log.levels.ERROR)
		return
	end

	vim.notify("[local_config]: loaded local config file", vim.log.levels.INFO)
end

return M
