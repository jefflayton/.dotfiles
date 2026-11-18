local fzf = require("fzf-lua")

vim.env.RIPGREP_CONFIG_PATH = vim.env.RIPGREP_CONFIG_PATH or vim.fn.expand("~/.config/ripgrep/.ripgreprc")

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
	"--exclude .svelte-kit",
	"--exclude .expo",
	"--exclude '*.lock'",
	"--exclude '*lock.json'",
	"--exclude '*lock.yaml'",
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
vim.keymap.set("n", "<leader>s", function()
	if require("fzf-lua.path").is_jj_repo(nil, true) then
		fzf.jj_files({ cmd = "jj diff --name-only", winopts = { title = " Changed Files (jj) " } })
	else
		fzf.git_status()
	end
end, { desc = "fzf: Changed Files" })
