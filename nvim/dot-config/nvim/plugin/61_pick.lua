local fzf = require("fzf-lua")

local fd_opts = table.concat({
	"--hidden", "--no-ignore", "--type f",
	"--exclude .git",
	"--exclude .jj",
	"--exclude node_modules",
	"--exclude .zig-cache",
	"--exclude zig-pkg",
	"--exclude ios",
	"--exclude android",
	"--exclude dist",
	"--exclude build",
	"--exclude '*.lock'",
	"--exclude '*lock.json'",
	"--exclude '*lock.yaml'",
	"--exclude '*.uid'",
	"--exclude '*.import'",
	"--exclude .godot",
	"--exclude .mono",
	"--exclude 'godot*.tmp'",
}, " ")

fzf.setup({
	winopts = {
		preview = {
			default = "bat",
		},
	},
	fzf_opts = {
		["--cycle"] = true,
	},
	files = {
		fd_opts = fd_opts,
	},
})

fzf.register_ui_select()

vim.keymap.set("n", "<leader>f", function()
	fzf.files()
end, { desc = "fzf: Files" })
vim.keymap.set("n", "<leader>b", function()
	fzf.buffers()
end, { desc = "fzf: Buffers" })
vim.keymap.set("n", "<leader>g", function()
	fzf.live_grep_native()
end, { desc = "fzf: Live Grep" })
vim.keymap.set("n", "<leader>ht", function()
	fzf.helptags()
end, { desc = "fzf: Help Tags" })
vim.keymap.set("n", "<leader>j", function()
	fzf.jj_files()
end, { desc = "fzf: JJ Files" })
