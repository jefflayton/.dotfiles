local validate = vim.validate
local nvim_eleven = 1

local M = {}

local function escape_wildcards(path)
	return path:gsub("([%[%]%?%*])", "\\%1")
end

function M.root_pattern(...)
	local patterns = M.tbl_flatten({ ... })
	return function(startpath)
		startpath = M.strip_archive_subpath(startpath)
		for _, pattern in ipairs(patterns) do
			local match = M.search_ancestors(startpath, function(path)
				for _, p in ipairs(vim.fn.glob(table.concat({ escape_wildcards(path), pattern }, "/"), true, true)) do
					---@diagnostic disable-next-line: undefined-field
					if vim.uv.fs_stat(p) then
						return path
					end
				end
			end)

			if match ~= nil then
				return match
			end
		end
	end
end

function M.tbl_flatten(t)
	--- @diagnostic disable-next-line:deprecated
	return nvim_eleven and vim.iter(t):flatten(math.huge):totable() or vim.tbl_flatten(t)
end

function M.search_ancestors(startpath, func)
	if nvim_eleven then
		validate("func", func, "function")
	end
	if func(startpath) then
		return startpath
	end
	local guard = 100
	for path in vim.fs.parents(startpath) do
		-- Prevent infinite recursion if our algorithm breaks
		guard = guard - 1
		if guard == 0 then
			return
		end

		if func(path) then
			return path
		end
	end
end

function M.strip_archive_subpath(path)
	-- Matches regex from zip.vim / tar.vim
	path = vim.fn.substitute(path, "zipfile://\\(.\\{-}\\)::[^\\\\].*$", "\\1", "")
	path = vim.fn.substitute(path, "tarfile:\\(.\\{-}\\)::.*$", "\\1", "")
	return path
end

function M.insert_package_json(root_files, field, fname, match)
	return M.root_markers_with_field(root_files, { "package.json", "package.json5" }, field, fname, match)
end

--- Appends `new_names` to `root_files` if `field` is found in any such file in any ancestor of `fname`.
---
--- NOTE: this does a "breadth-first" search, so is broken for multi-project workspaces:
--- https://github.com/neovim/nvim-lspconfig/issues/3818#issuecomment-2848836794
---
--- @param root_files string[] List of root-marker files to append to.
--- @param new_names string[] Potential root-marker filenames (e.g. `{ 'package.json', 'package.json5' }`) to inspect for the given `field`.
--- @param field string|string[] Field(s) to search for in the given `new_names` files.
--- @param fname string Full path of the current buffer name to start searching upwards from.
--- @param match? "any"|"all" Whether one field (default) or every field must be present.
function M.root_markers_with_field(root_files, new_names, field, fname, match)
	local path = vim.fn.fnamemodify(fname, ":h")
	local found = vim.fs.find(new_names, { path = path, upward = true })
	local fields = type(field) == "table" and field or { field }
	local need_all = match == "all"

	for _, f in ipairs(found or {}) do
		local hits, count = {}, 0
		for line in io.lines(f) do
			for _, pat in ipairs(fields) do
				if not hits[pat] and line:find(pat) then
					hits[pat] = true
					count = count + 1
				end
			end
			if count == #fields or (not need_all and count > 0) then
				break
			end
		end

		local ok = need_all and count == #fields or (not need_all and count > 0)
		if ok then
			root_files[#root_files + 1] = vim.fs.basename(f)
		end
	end

	return root_files
end

--- Returns a per-buffer picker choosing the tools whose config file is nearest the buffer.
--- Ties go to the earlier entry; no match falls back to the last entry.
--- @param tools table[] Array of tool configurations with 'paths' and 'tools' fields
--- @return fun(bufnr?: integer): string[]
function M.tool_decider(tools)
	return function(bufnr)
		local best, best_len = tools[#tools].tools, -1
		for _, tool in ipairs(tools) do
			local root = tool.paths and vim.fs.root(bufnr or 0, tool.paths)
			if root and #root > best_len then
				best, best_len = tool.tools, #root
			end
		end
		return best
	end
end

return M
