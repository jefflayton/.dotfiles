local files = require("mini.files")
files.setup({
	mappings = {
		synchronize = "<leader>w",
	},
})
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
