local original_set_lines = vim.api.nvim_buf_set_lines

local filter_godot_files = function(lines)
	local filtered = {}
	local godot_patterns = {
		"%.uid[/]?$", -- .uid files
		"%.import[/]?$", -- .import files
		"^%.godot[/]?$", -- .godot directory
		"^%.mono[/]?$", -- .mono directory
		"godot.*%.tmp$", -- godot temp files
	}

	for _, line in ipairs(lines) do
		local should_include = true
		for _, pattern in ipairs(godot_patterns) do
			if line:match(pattern) then
				should_include = false
				break
			end
		end
		if should_include then
			table.insert(filtered, line)
		end
	end
	return filtered
end

local files = require("mini.files")
files.setup({
	content = {
		filter = function(fs_entry)
			return true
		end,
	},
	mappings = {
		synchronize = "<leader>w",
	},
})
vim.api.nvim_buf_set_lines = function(buf_id, start, end_idx, strict_indexing, lines)
	local bufname = vim.api.nvim_buf_get_name(buf_id)
	if bufname:match("minifiles://") and type(lines) == "table" then
		lines = filter_godot_files(lines)
	end
	return original_set_lines(buf_id, start, end_idx, strict_indexing, lines)
end

vim.keymap.set("n", "<leader>e", function(...)
	if not files.close() then
		files.open(...)
	end
end, { desc = "MiniFiles: Open" })

local map_split = function(buf_id, lhs, direction)
	local rhs = function()
		local cur_target = files.get_explorer_state().target_window
		vim.api.nvim_win_call(cur_target, function()
			vim.cmd(direction .. " split")
			return vim.api.nvim_get_current_win()
		end)
		files.go_in()
		files.close()
		vim.api.nvim_set_current_win(cur_target)
	end

	local desc = "Split " .. direction
	vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local ui_open = function()
	vim.ui.open(files.get_fs_entry().path)
end

local set_cwd = function()
	local path = (files.get_fs_entry() or {}).path
	if path == nil then
		return vim.notify("Cursor is not on valid entry")
	end
	vim.fn.chdir(vim.fs.dirname(path))
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesBufferCreate",
	callback = function(args)
		local buf_id = args.data.buf_id
		map_split(buf_id, "<C-s>", "belowright horizontal")
		map_split(buf_id, "<C-v>", "belowright vertical")
		vim.keymap.set("n", "gX", ui_open, { buffer = buf_id, desc = "OS open" })
		vim.keymap.set("n", "g~", set_cwd, { buffer = buf_id, desc = "Set cwd" })
	end,
})
