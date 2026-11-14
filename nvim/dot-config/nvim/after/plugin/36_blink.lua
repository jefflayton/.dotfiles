local luasnip = require("luasnip")
luasnip.setup()
require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/snippets/" })

local function get_mini_icon(ctx)
	if ctx.source_name == "Path" then
		local is_unknown_type =
			vim.tbl_contains({ "link", "socket", "fifo", "char", "block", "unknown" }, ctx.item.data.type)
		local mini_icon, mini_hl, _ = require("mini.icons").get(
			is_unknown_type and "os" or ctx.item.data.type,
			is_unknown_type and "" or ctx.label
		)
		if mini_icon then
			return mini_icon, mini_hl
		end
	end
	local mini_icon, mini_hl, _ = require("mini.icons").get("lsp", ctx.kind)
	return mini_icon, mini_hl
end

require("blink.cmp").setup({
	snippets = {
		preset = "luasnip",
	},
	cmdline = {
		completion = {
			menu = { auto_show = true },
		},
		keymap = { preset = "inherit" },
	},
	completion = {
		documentation = { auto_show = false, window = { border = "single" } },
		menu = {
			draw = {
				treesitter = { "lsp" },
				columns = {
					{ "kind_icon", "label", "label_description", gap = 1 },
					{ "source_id" },
				},
				components = {
					kind_icon = {
						text = function(ctx)
							local kind_icon, kind_hl = get_mini_icon(ctx)
							_ = kind_hl
							return kind_icon
						end,
						-- (optional) use highlights from mini.icons
						highlight = function(ctx)
							local _, hl = get_mini_icon(ctx)
							return hl
						end,
					},
					kind = {
						-- (optional) use highlights from mini.icons
						highlight = function(ctx)
							local _, hl = get_mini_icon(ctx)
							return hl
						end,
					},
				},
			},
		},
	},
	keymap = {
		["<C-e>"] = { "show", "show_documentation", "hide_documentation" },

		["<Tab>"] = {
			function(cmp)
				if cmp.snippet_active() then
					return cmp.accept()
				else
					return cmp.select_and_accept()
				end
			end,
			"fallback",
		},

		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-p>"] = { "select_prev", "fallback" },
		["<C-n>"] = { "select_next", "fallback" },

		["<C-b>"] = { "scroll_documentation_up", "fallback" },
		["<C-f>"] = { "scroll_documentation_down", "fallback" },

		["<C-K>"] = { "snippet_forward" },
		["<C-J>"] = { "snippet_backward" },
	},
	sources = {
		default = { "lsp", "dadbod", "path", "snippets", "buffer" },
		providers = {
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			buffer = {
				-- keep case of first char
				transform_items = function(a, items)
					local ft = vim.bo.filetype
					if ft ~= "text" and ft ~= "markdown" and ft ~= "typst" then
						return items
					end

					local keyword = a.get_keyword()
					local correct, case
					if keyword:match("^%l") then
						correct = "^%u%l+$"
						case = string.lower
					elseif keyword:match("^%u") then
						correct = "^%l+$"
						case = string.upper
					else
						return items
					end

					-- avoid duplicates from the corrections
					local seen = {}
					local out = {}
					for _, item in ipairs(items) do
						local raw = item.insertText
						if raw:match(correct) then
							local text = case(raw:sub(1, 1)) .. raw:sub(2)
							item.insertText = text
							item.label = text
						end
						if not seen[item.insertText] then
							seen[item.insertText] = true
							table.insert(out, item)
						end
					end
					return out
				end,
			},
			snippets = {
				name = "Snippets",
				module = "blink.cmp.sources.snippets",
				min_keyword_length = 2,
			},
		},
	},
	fuzzy = {
		implementation = "prefer_rust_with_warning",
	},
})
