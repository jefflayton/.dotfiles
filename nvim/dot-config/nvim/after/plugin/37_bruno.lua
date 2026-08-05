require("bruno").setup({
	picker = "fzf-lua",
	show_formatted_output = true,
	suppress_formatting_errors = false,
})

vim.keymap.set("n", "<leader>cr", "<cmd>BrunoRun<cr>", { desc = "Bruno: Run" })
vim.keymap.set("n", "<leader>ce", "<cmd>BrunoEnv<cr>", { desc = "Bruno: Env" })
vim.keymap.set("n", "<leader>cs", "<cmd>BrunoSearch<cr>", { desc = "Bruno: Search" })
vim.keymap.set("n", "<leader>ctf", "<cmd>BrunoToggleFormat<cr>", { desc = "Bruno: Toggle Format" })
