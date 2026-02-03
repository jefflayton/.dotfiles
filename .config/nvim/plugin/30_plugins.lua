local gh = function(plugin)
	return "https://github.com/" .. plugin
end

vim.pack.add({
	gh("catppuccin/nvim"),
	gh("folke/flash.nvim"),
	gh("shortcuts/no-neck-pain.nvim"),
	gh("MunifTanjim/nui.nvim"),
	gh("mason-org/mason.nvim"),

	-- Git
	gh("lewis6991/gitsigns.nvim"),
	gh("kokusenz/deltaview.nvim"),

	-- Dadbod
	gh("kristijanhusak/vim-dadbod-ui"),
	gh("tpope/vim-dadbod"),
	gh("tpope/vim-dotenv"),
	gh("kristijanhusak/vim-dadbod-completion"),

	-- External Configs
	-- 31_treesitter
	gh("nvim-treesitter/nvim-treesitter"),

	-- 32_notes
	gh("preservim/vim-pencil"),
	gh("OXY2DEV/markview.nvim"),
	-- gh("nvim-neorg/neorg"), -- Doesn't work in 0.12-dev

	-- 33_dap
	gh("mfussenegger/nvim-dap"),
	gh("jbyuki/one-small-step-for-vimkind"),
	gh("miroshQa/debugmaster.nvim"),

	-- after/plugin
	-- 30_conform
	gh("stevearc/conform.nvim"),
	-- 31_lint
	gh("mfussenegger/nvim-lint"),

	-- typescript
	gh("enochchau/nvim-pretty-ts-errors"),
})

-- Execute Plugin Hooks
local hooks = function(ev)
	local name, kind = ev.data.spec.name, ev.data.kind
	if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
		if not ev.data.active then
			vim.cmd.packadd("nvim-treesitter")
		end
		vim.cmd("TSUpdate")
	end

	if name == "enochchau/nvim-pretty-ts-errors" and (kind == "install" or kind == "update") then
		if not ev.data.active then
			vim.cmd.packadd("enochchau/nvim-pretty-ts-errors")
		end
		vim.system({ "npm", "install" }, { cwd = ev.data.path })
	end

	if name == "kristijanhusak/vim-dadbod-ui" and kind == "install" then
		vim.g.db_ui_use_nerd_fonts = 1
		vim.g.db_ui_env_variable_url = "DATABASE_URL"
	end

	if name == "L3MON4D3/LuaSnip" and (kind == "install" or kind == "update") then
		if not ev.data.active then
			vim.cmd.packadd("L3MON4D3/LuaSnip")
		end
		vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path })
	end
end
vim.api.nvim_create_autocmd("PackChanged", { callback = hooks })

-- Theme
require("catppuccin").setup({
	flavor = "mocha",
	float = {
		transparent = true,
		solid = true,
	},
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
})
vim.cmd.colorscheme("catppuccin")

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

-- Dadbod
vim.keymap.set("n", "<c-b>u", "<cmd>DBUIToggle<cr>", { desc = "DB: Toggle UI" })
vim.keymap.set("n", "<c-b>f", "<cmd>DBUIFindBuffer<cr>", { desc = "DB: Find Buffer" })
vim.keymap.set("n", "<leader>le", "<cmd>Dotenv<cr>", { desc = "Dotenv: Load" })

-- No Neck Pain
require("no-neck-pain").setup({ width = 150 })
vim.keymap.set("n", "<leader>np", "<CMD>NoNeckPain<CR>", { desc = "NoNeckPain: Toggle" })
vim.keymap.set("n", "<leader>nl", "<CMD>NoNeckPainToggleLeftSide<CR>", { desc = "NoNeckPain: Toggle Left Side" })
vim.keymap.set("n", "<leader>nr", "<CMD>NoNeckPainToggleRightSide<CR>", { desc = "NoNeckPain: Toggle Right Side" })

require("mason").setup()
