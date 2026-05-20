local fzf = require("fzf-lua")
fzf.setup({
	winopts = {
		preview = {
			default = "bat",
		},
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
