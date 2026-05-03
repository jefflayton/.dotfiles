local os = require("overseer")
os.setup()
vim.keymap.set("n", "<leader>or", "<cmd>OverseerRun<cr>", { desc = "Overseer: Run" })
vim.keymap.set("n", "<leader>oo", "<cmd>OverseerOpen<cr>", { desc = "Overseer: Open" })
vim.keymap.set("n", "<leader>oc", "<cmd>OverseerClose<cr>", { desc = "Overseer: Close" })
os.register_template({
	name = "Zig Build",
	builder = function()
		return {
			cmd = { "zig", "build" },
			cwd = vim.fn.getcwd(),
		}
	end,
	condition = { filetype = { "zig" } },
})
