local ok, err = pcall(function()
	local buf = vim.api.nvim_create_buf(false, true)
	local parser = vim.treesitter.get_parser(buf, "sql", {
		error = false,
		injections = {},
	})
	print(vim.inspect(parser))
end)
print(ok, err)
