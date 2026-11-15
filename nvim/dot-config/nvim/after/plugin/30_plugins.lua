require("rainbow_csv").setup()
require("grug-far").setup({
	windowCreationCommand = "aboveleft split",
})
vim.keymap.set("n", "<c-s>u", function()
	require("grug-far").open({
		transient = true,
	})
end, { desc = "GrugFar: Open" })
vim.keymap.set("n", "<c-s>w", function()
	require("grug-far").open({
		transient = true,
		visualSelectionUsage = "operate-within-range",
	})
end, { desc = "GrugFar: Within" })

require("debugprint").setup({
	highlight_lines = false,
	display_counter = false,
	print_tag = "",
})

-- Flash
local flash = require("flash")
flash.setup({
	modes = { search = { enabled = false } },
})
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

-- Git
local gs = require("gitsigns")
gs.setup({ current_line_blame = true })
vim.keymap.set("n", "]c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "]c", bang = true })
	else
		gs.nav_hunk("next")
	end
end, { desc = "GitSigns: Next Hunk" })

vim.keymap.set("n", "[c", function()
	if vim.wo.diff then
		vim.cmd.normal({ "[c", bang = true })
	else
		gs.nav_hunk("prev")
	end
end, { desc = "GitSigns: Prev Hunk" })
vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { desc = "GitSigns: Preview Hunk" })
vim.keymap.set("n", "<leader>hi", gs.preview_hunk_inline, { desc = "GitSigns: Preview Hunk Inline" })
vim.keymap.set("n", "<leader>hd", gs.diffthis, { desc = "GitSigns: Diff This" })
vim.keymap.set("n", "<leader>hq", gs.setqflist, { desc = "GitSigns: Set Quick Fix List" })
vim.keymap.set("n", "<leader>hQ", function()
	gs.setqflist("all")
end, { desc = "GitSigns: Set Quick Fix List, All" })

require("octo").setup({ picker = "fzf-lua" })
vim.keymap.set("n", "<leader>op", "<cmd>Octo pr list<cr>", { desc = "Octo: PR List" })
vim.keymap.set("n", "<leader>om", "<cmd>Octo search is:pr is:open author:@me<cr>", { desc = "Octo: My PRs" })
vim.keymap.set("n", "<leader>or","<cmd>Octo review<cr>", { desc = "Octo: Review PR" })

-- Dadbod
vim.keymap.set("n", "<c-b>u", "<cmd>DBUIToggle<cr>", { desc = "DB: Toggle UI" })
vim.keymap.set("n", "<c-b>f", "<cmd>DBUIFindBuffer<cr>", { desc = "DB: Find Buffer" })
vim.keymap.set("n", "<leader>le", "<cmd>Dotenv<cr>", { desc = "Dotenv: Load" })

require("snacks").setup({
	image = {
		enabled = true,
		math = {
			enabled = false,
		},
	},

	-- Disabled
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = false },
	input = { enabled = false },
	notifier = { enabled = false },
	picker = { enabled = false },
	quickfile = { enabled = false },
	scope = { enabled = false },
	scroll = { enabled = false },
	statuscolumn = { enabled = false },
	words = { enabled = false },
})

local hover_providers = {
	"hover.providers.diagnostic",
	"hover.providers.lsp",
	"hover.providers.dap",
	"hover.providers.gh",
	"hover.providers.gh_user",
	"hover.providers.jira",
	"hover.providers.fold_preview",
}
require("hover").setup({
	providers = hover_providers,

	preview_opts = {
		border = "single",
	},
	-- Whether the contents of a currently open hover window should be moved
	-- to a :h preview-window when pressing the hover keymap.
	preview_window = true,
	title = false,
	mouse_providers = hover_providers,
	mouse_delay = 1000,
})
vim.keymap.set("n", "K", function()
	require("hover").open()
end, { desc = "hover.nvim (open)" })

vim.keymap.set("n", "gK", function()
	require("hover").enter()
end, { desc = "hover.nvim (enter)" })

vim.keymap.set("n", "<C-p>", function()
	require("hover").switch("previous")
end, { desc = "hover.nvim (previous source)" })

vim.keymap.set("n", "<C-n>", function()
	require("hover").switch("next")
end, { desc = "hover.nvim (next source)" })
