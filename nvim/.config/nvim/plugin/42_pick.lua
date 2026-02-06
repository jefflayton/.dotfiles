local pick = require("mini.pick")
pick.setup({ options = { use_cache = true } })

pick.registry.buffers = function(local_opts, opts)
	local_opts = local_opts or {}

	-- Delete the current buffer
	local wipeout_cur = function()
		vim.api.nvim_buf_delete(pick.get_picker_matches().current.bufnr, { force = true })
		pick.builtin.buffers(local_opts, opts)
	end

	-- Map <C-d> to delete the buffer
	local buffer_mappings = { wipeout = { char = "<C-d>", func = wipeout_cur } }

	-- Merge options
	opts = vim.tbl_deep_extend("force", {
		mappings = buffer_mappings,
	}, opts or {})

	return pick.builtin.buffers(local_opts, opts)
end

vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		local args = vim.fn.argv()
		if #args == 0 then
			vim.schedule(function()
				pick.builtin.files({ tool = "rg" })
			end)
		end
	end,
})

local nmap = function(keymap, action, desc)
	vim.keymap.set("n", keymap, action, { desc = "MiniPick: " .. desc })
end
nmap("<leader>f", function()
	pick.builtin.files({ tool = "rg" })
end, "Files")
nmap("<leader>g", function()
	pick.builtin.grep_live({ tool = "rg" })
end, "Live Grep")
nmap("<leader>b", function()
	pick.registry.buffers({ tool = "rg" })
end, "Buffers")
nmap("<leader>h", function()
	pick.builtin.help({ tool = "rg" })
end, "Help")
