require("rainbow_csv").setup()
-- require("grug-far").setup() -- Doesn't work in 0.12-dev

require("debugprint").setup({
	highlight_lines = false,
	display_counter = false,
	print_tag = "",
})

-- Flash
local flash = require("flash")
vim.keymap.set({ "n", "x", "o" }, "zk", function()
	flash.jump()
end, { desc = "Flash: Jump" })
vim.keymap.set({ "n", "x", "o" }, "zK", function()
	flash.treesitter()
end, { desc = "Flash: Treesitter" })
vim.keymap.set("o", "r", function()
	flash.remote()
end, { desc = "Flash: Remote" })
vim.keymap.set({ "o", "x" }, "R", function()
	flash.treesitter_search()
end, { desc = "Flash: Treesitter Search" })
vim.keymap.set("c", "<c-s>", function()
	flash.toggle()
end, { desc = "Flash: Toggle Search" })

-- No Neck Pain
require("no-neck-pain").setup({ width = 150 })
vim.keymap.set("n", "<leader>np", "<cmd>NoNeckPain<cr>", { desc = "NoNeckPain: Toggle" })
vim.keymap.set("n", "<leader>nl", "<cmd>NoNeckPainToggleLeftSide<cr>", { desc = "NoNeckPain: Toggle Left Side" })
vim.keymap.set("n", "<leader>nr", "<cmd>NoNeckPainToggleRightSide<cr>", { desc = "NoNeckPain: Toggle Right Side" })

-- Overseer
require("overseer").setup()
vim.keymap.set("n", "<leader>oo", "<cmd>OverseerRun<cr>", { desc = "Overseer: Run" })
vim.keymap.set("n", "<leader>oo", "<cmd>OverseerOpen<cr>", { desc = "Overseer: Open" })
vim.keymap.set("n", "<leader>oc", "<cmd>OverseerClose<cr>", { desc = "Overseer: Close" })

-- Git
require("gitsigns").setup({ current_line_blame = true })
require("deltaview").setup({
	keyconfig = {
		-- Global
		dv_toggle_keybind = "<C-d>f",
		dm_toggle_keybind = "<C-d>m",
		d_toggle_keybind = "<C-d>u",

		-- In Diff
		next_hunk = "]c",
		prev_hunk = "[c",
		next_diff = "]f",
		prev_diff = "[f",
		fzf_toggle = "",
		jump_to_line = "<CR>",
	},
	use_nerdfonts = true,
})

-- Dadbod
vim.keymap.set("n", "<c-b>u", "<cmd>DBUIToggle<cr>", { desc = "DB: Toggle UI" })
vim.keymap.set("n", "<c-b>f", "<cmd>DBUIFindBuffer<cr>", { desc = "DB: Find Buffer" })
vim.keymap.set("n", "<leader>le", "<cmd>Dotenv<cr>", { desc = "Dotenv: Load" })
