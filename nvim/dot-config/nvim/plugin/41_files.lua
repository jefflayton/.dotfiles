local files = require("mini.files")
files.setup({
	mappings = {
		synchronize = "<leader>w",
	},
	windows = {
		max_number = 3, -- parent, focus, preview
		preview = true,
	},
})

-- Fit the columns into a centered box of at most MAX_WIDTH.
-- Below MIN_THREE (e.g. a split laptop screen) drop the parent column so focus + preview stay readable.
local MAX_WIDTH, MIN_THREE = 120, 100
local box_width
local fit_windows = function()
	local w = files.config.windows
	box_width = math.min(vim.o.columns - 2, MAX_WIDTH)
	local three = box_width >= MIN_THREE
	w.max_number = three and 3 or 2
	local total = box_width - 2 * w.max_number -- one left and one right border per window
	w.width_nofocus = math.floor(total * 0.2)
	w.width_focus = math.floor(total * (three and 0.35 or 0.45))
	w.width_preview = total - w.width_focus - (three and w.width_nofocus or 0)
end
fit_windows()

-- Center the full 3-column layout. Its left edge stays fixed so columns don't jump while navigating.
local center_window = function(win_id)
	local state = files.get_explorer_state()
	if state == nil or not vim.api.nvim_win_is_valid(win_id) then
		return
	end
	local col = math.floor((vim.o.columns - box_width) / 2)
	-- Recompute from scratch: this event also fires on height-only updates that keep the previous col.
	for _, win in ipairs(state.windows) do
		if win.win_id == win_id then
			break
		end
		col = col + vim.api.nvim_win_get_width(win.win_id) + 2
	end
	local config = vim.api.nvim_win_get_config(win_id)
	config.col = math.max(col, 0)
	vim.api.nvim_win_set_config(win_id, config)
end

vim.api.nvim_create_autocmd("User", {
	pattern = "MiniFilesWindowUpdate",
	callback = function(args)
		-- Explorer state isn't registered yet while it's first opening.
		if files.get_explorer_state() == nil then
			return vim.schedule(function()
				center_window(args.data.win_id)
			end)
		end
		center_window(args.data.win_id)
	end,
})

vim.keymap.set("n", "<leader>e", function(...)
	if not files.close() then
		fit_windows()
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

-- Opened by Rex cmd+e (rex/files.lua): cd the shell pane it was opened from.
local cd_origin = function(dir)
	local origin = vim.env.REX_ORIGIN_BLOCK
	if origin == nil or origin == "" then
		return
	end
	return vim.system({ vim.env.REX_BIN, "do", "cd_pane", "block=" .. origin, "dir=" .. dir })
end

-- On exit, write the cwd for the launcher to cd into (fish functions/nvim.fish, rex/files.lua).
local cwd_file = vim.env.NVIM_CWD_FILE
vim.env.NVIM_CWD_FILE = nil -- don't let nested nvims (e.g. git in :terminal) write to it
if cwd_file ~= nil and cwd_file ~= "" then
	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			vim.fn.writefile({ vim.fn.getcwd() }, cwd_file)
		end,
	})
end

-- cd to the directory shown in the focused column (works in empty directories too).
local set_cwd = function()
	local state = files.get_explorer_state()
	local dir = state.branch[state.depth_focus]
	vim.fn.chdir(dir)
	cd_origin(dir)
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
