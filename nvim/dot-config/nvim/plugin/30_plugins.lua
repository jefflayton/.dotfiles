local gh = function(plugin)
	return "https://github.com/" .. plugin
end
-- local cb = function(plugin)
-- 	return "https://codeberg.org/" .. plugin
-- end

vim.cmd("packadd nvim.undotree")
vim.pack.add({
	gh("sainnhe/gruvbox-material"),
	gh("MunifTanjim/nui.nvim"),
	gh("mason-org/mason.nvim"),

	-- External Configs
	-- 31_treesitter
	gh("nvim-treesitter/nvim-treesitter"),
	gh("windwp/nvim-ts-autotag"),

	-- 61_fzf
	gh("ibhagwan/fzf-lua"),

	-- 51_godot
	gh("Mathijs-Bakker/godotdev.nvim"),

	-- after/plugin
	-- 30_plugins
	gh("cameron-wags/rainbow_csv.nvim"),
	gh("MagicDuck/grug-far.nvim"),
	gh("andrewferrier/debugprint.nvim"),
	gh("folke/flash.nvim"),
	gh("shortcuts/no-neck-pain.nvim"),
	gh("folke/snacks.nvim"),
	gh("lewis6991/hover.nvim"),
	gh("not-manu/filemention.nvim"),

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
	-- 35_overseer
	gh("stevearc/overseer.nvim"),
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
	-- 37_bruno
	gh("nvim-lua/plenary.nvim"),
	gh("romek-codes/bruno.nvim"),

	-- after/ftplugin
	-- typescript
	gh("enochchau/nvim-pretty-ts-errors"),
})

vim.keymap.set("n", "<leader>t", require("nvim-pretty-ts-errors").show_line_diagnostics)

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

	if name == "saghen/blink.cmp" and (kind == "install" or kind == "update") then
		vim.system({ "cargo", "build", "--release" })
	end
end
vim.api.nvim_create_autocmd("PackChanged", { callback = hooks })

-- Theme
vim.g.gruvbox_material_enable_italic = false
vim.g.gruvbox_material_foreground = "mix"
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_float_style = "blend"
vim.g.gruvbox_material_transparent_background = 2
vim.g.gruvbox_material_better_performance = 1
vim.cmd.colorscheme("gruvbox-material")

require("mason").setup()

-- Godot
vim.g.godot_executable = "/Applications/Godot.app/Contents/MacOS/Godot"
