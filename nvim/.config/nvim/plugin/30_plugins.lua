local gh = function(plugin)
	return "https://github.com/" .. plugin
end

vim.pack.add({
	gh("catppuccin/nvim"),
	gh("MunifTanjim/nui.nvim"),
	gh("mason-org/mason.nvim"),

	-- External Configs
	-- 31_treesitter
	gh("nvim-treesitter/nvim-treesitter"),
	gh("windwp/nvim-ts-autotag"),

	-- 33_dap
	gh("mfussenegger/nvim-dap"),
	gh("jbyuki/one-small-step-for-vimkind"),
	gh("miroshQa/debugmaster.nvim"),

	-- after/plugin
	-- 30_plugins
	gh("cameron-wags/rainbow_csv.nvim"),
	-- gh("MagicDuck/grug-far.nvim"), -- Doesn't work in 0.12-dev
	gh("andrewferrier/debugprint.nvim"),
	gh("folke/flash.nvim"),
	gh("shortcuts/no-neck-pain.nvim"),
	gh("stevearc/overseer.nvim"),
	-- Git
	gh("lewis6991/gitsigns.nvim"),
	gh("kokusenz/deltaview.nvim"),
	-- Dadbod
	gh("kristijanhusak/vim-dadbod-ui"),
	gh("tpope/vim-dadbod"),
	gh("tpope/vim-dotenv"),
	gh("kristijanhusak/vim-dadbod-completion"),

	-- 31_conform
	gh("stevearc/conform.nvim"),
	-- 32_lint
	gh("mfussenegger/nvim-lint"),
	-- 33_notes
	gh("preservim/vim-pencil"),
	gh("OXY2DEV/markview.nvim"),
	gh("nvim-orgmode/orgmode"),

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
		solid = false,
	},
	compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
})
vim.cmd.colorscheme("catppuccin")

require("mason").setup()
