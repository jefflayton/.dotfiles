local gh = function(plugin)
	return "https://github.com/" .. plugin
end
-- local cb = function(plugin)
-- 	return "https://codeberg.org/" .. plugin
-- end

vim.cmd("packadd nvim.undotree")
vim.pack.add({
	gh("sainnhe/gruvbox-material"),

	-- External Configs
	-- 31_treesitter
	gh("nvim-treesitter/nvim-treesitter"),
	gh("windwp/nvim-ts-autotag"),

	-- 61_fzf
	gh("ibhagwan/fzf-lua"),

	-- after/plugin
	-- 30_plugins
	gh("cameron-wags/rainbow_csv.nvim"),
	gh("MagicDuck/grug-far.nvim"),
	gh("andrewferrier/debugprint.nvim"),
	gh("folke/flash.nvim"),
	gh("shortcuts/no-neck-pain.nvim"),
	gh("folke/snacks.nvim"),
	gh("lewis6991/hover.nvim"),

	-- Git
	gh("lewis6991/gitsigns.nvim"),

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
	-- 34_dap
	gh("mfussenegger/nvim-dap"),
	gh("jbyuki/one-small-step-for-vimkind"),
	gh("miroshQa/debugmaster.nvim"),
	-- 36_blink
	gh("rafamadriz/friendly-snippets"),
	{
		src = gh("L3MON4D3/LuaSnip"),
		version = vim.version.range("2.*"),
	},
	{
		src = gh("saghen/blink.cmp"),
		version = vim.version.range("1.*"),
	},
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

	if name == "LuaSnip" and (kind == "install" or kind == "update") then
		vim.system({ "make", "install_jsregexp" }, { cwd = ev.data.path })
	end
end
vim.api.nvim_create_autocmd("PackChanged", { callback = hooks })

-- Dadbod
vim.g.db_ui_use_nerd_fonts = 1
vim.g.db_ui_env_variable_url = "DATABASE_URL"

-- Theme
vim.g.gruvbox_material_enable_italic = false
vim.g.gruvbox_material_foreground = "mix"
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_float_style = "blend"
vim.g.gruvbox_material_transparent_background = 2
vim.g.gruvbox_material_better_performance = 1
vim.cmd.colorscheme("gruvbox-material")

