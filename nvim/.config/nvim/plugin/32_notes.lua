require("markview").setup({
	preview = { icon_provider = "mini" },
	typst = {
		code_blocks = { enable = false },
		code_spans = { enable = false },
	},
})
require("markview.extras.checkboxes").setup()

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "text", "markdown", "typst" },
	callback = function()
		vim.cmd("PencilSoft")
		vim.keymap.set("n", "<leader>ct", "<cmd>Checkbox toggle<cr>", { desc = "Markview: Toggle Checkbox" })
	end,
})

-- Doesn't work in 0.12-dev
-- require("neorg").setup({
-- 	load = {
-- 		["core.defaults"] = {},
-- 		["core.dirman"] = {
-- 			config = {
-- 				workspaces = {
-- 					notes = "~/Documents/notes",
-- 				},
-- 			},
-- 		},
-- 		["core.concealer"] = {}, -- We added this line!
-- 	},
-- })
