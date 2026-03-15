require("mini.extra").setup()

require("mini.icons").setup()
require("mini.icons").mock_nvim_web_devicons()

require("mini.bracketed").setup()
require("mini.comment").setup()
require("mini.git").setup()
require("mini.keymap").setup()
require("mini.move").setup()
require("mini.notify").setup()
require("mini.splitjoin").setup()
require("mini.surround").setup()

local gen_ai_spec = require("mini.extra").gen_ai_spec
require("mini.ai").setup({
	custom_textobjects = {
		B = gen_ai_spec.buffer(),
		D = gen_ai_spec.diagnostic(),
		I = gen_ai_spec.indent(),
		L = gen_ai_spec.line(),
		N = gen_ai_spec.number(),
	},
})

require("mini.pairs").setup()

local indent = require("mini.indentscope")
indent.setup({
	draw = {
		delay = 0,
		animation = indent.gen_animation.none(),
	},
	options = { try_as_border = true },
	symbol = "▎",
})

local gen_clues = require("mini.clue").gen_clues
require("mini.clue").setup({
	window = {
		delay = 500,
	},
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },

		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },

		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },

		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },

		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },

		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },

		-- Window commands
		{ mode = "n", keys = "<C-w>" },

		{ mode = "n", keys = "[" },
		{ mode = "n", keys = "]" },

		-- Custom Keymaps --
		-- DB
		{ mode = "n", keys = "<C-b>" },
		--  Tabs
		{ mode = "n", keys = "<C-t>" },
		-- Diff
		{ mode = "n", keys = "<C-d>" },
		-- Grug
		{ mode = "n", keys = "<C-r>" },
	},

	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		gen_clues.builtin_completion(),
		gen_clues.g(),
		gen_clues.marks(),
		gen_clues.registers(),
		gen_clues.windows(),
		gen_clues.z(),
	},
})

local function get_words()
	local count = nil

	local filetype = vim.bo.filetype
	if vim.fn.mode() == "v" or vim.fn.mode() == "V" or vim.fn.mode() == "" then
		count = vim.fn.wordcount().visual_words
	elseif filetype == "text" or filetype == "markdown" or filetype == "typst" then
		count = vim.fn.wordcount().words
	else
		count = nil
	end

	if count == nil then
		return
	end

	local suffix = " words"
	if count == 1 then
		suffix = " word"
	end

	return tostring(count) .. suffix .. " │"
end

local statusline = require("mini.statusline")
statusline.setup({
	-- Use default content
	content = {
		active = function()
			local mode, mode_hl = statusline.section_mode({ trunc_width = 120 })
			local git = statusline.section_git({ trunc_width = 40 })
			local diff = statusline.section_diff({ trunc_width = 75 })
			local diagnostics = statusline.section_diagnostics({
				icon = "",
				trunc_width = 75,
				signs = {
					ERROR = "%#DiagnosticError#!",
					WARN = "%#DiagnosticWarn#?",
					INFO = "%#DiagnosticInfo#@",
					HINT = "%#DiagnosticHint#*",
				},
			})
			-- local lsp = statusline.section_lsp({ trunc_width = 75 })
			local filename = statusline.section_filename({ trunc_width = 140 })
			-- local fileinfo = statusline.section_fileinfo({ trunc_width = 120 })
			local location = statusline.section_location({ trunc_width = 10000 })
			-- local search = statusline.section_searchcount({ trunc_width = 75 })

			local function get_filetype_with_icon()
				local ft = vim.bo.filetype
				if ft == "" then
					return "no ft"
				end

				-- Get icon using mini.icons
				local has_mini_icons, mini_icons = pcall(require, "mini.icons")
				if has_mini_icons then
					local icon = mini_icons.get("filetype", ft)
					if icon then
						return icon .. " " .. ft
					end
				end

				return ft
			end
			local filetype = get_filetype_with_icon()

			local dmode_enabled = require("debugmaster.debug.mode").is_active()

			local dmode = function()
				if statusline.is_truncated(120) then
					return "D"
				end
				return "DEBUG"
			end
			mode = dmode_enabled and dmode() or mode
			mode_hl = dmode_enabled and "dCursor" or mode_hl

			if #diagnostics > 0 then
				diagnostics = "│" .. diagnostics
			end

			return statusline.combine_groups({
				{ hl = mode_hl, strings = { mode } },
				{ hl = "MiniStatuslineDevinfo", strings = { git } },
				"%<", -- Mark general truncate point
				{ hl = "MiniStatuslineFilename", strings = { filename } },
				"%=", -- End left alignment
				{ hl = "MiniStatuslineFilename", strings = { diff, diagnostics } },
				{ hl = "MiniStatuslineFileinfo", strings = { get_words(), location } },
				{ hl = mode_hl, strings = { filetype } },
			})
		end,
	},
	use_icons = true,
})
