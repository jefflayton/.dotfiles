local add, now = require("mini.deps").add, require("mini.deps").now

now(function()
	add({
		source = "catppuccin/nvim",
	})
	require("catppuccin").setup({
		flavor = "mocha",
		float = {
			transparent = true,
			solid = true,
		},
		compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
	})
	vim.cmd.colorscheme("catppuccin")
end)
