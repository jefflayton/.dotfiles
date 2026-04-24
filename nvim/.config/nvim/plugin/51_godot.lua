require("godotdev").setup({
	formatter = false,
	treesitter = { auto_setup = false },
})
vim.keymap.set("n", "gK", "<cmd>GodotDocs<cr>", { desc = "Godot docs" })
