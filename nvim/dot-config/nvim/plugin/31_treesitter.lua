local ts = require("nvim-treesitter")

local languages = {
    "bash",
    "bicep",
    "c",
    "cpp",
    "css",
    "dockerfile",
    "fish",
    "html",
    "http",
    "javascript",
    "jsdoc",
    "json",
    "lua",
    "make",
    "markdown",
    "markdown_inline",
    "nix",
    "odin",
    "regex",
    "rust",
    "sql",
    "swift",
    "svelte",
    "toml",
    "typescript",
    "typst",
    "vim",
    "vimdoc",
    "yaml",
    "zig",
}

-- Look for the parser file instead of loading the parser: much faster at startup.
local not_installed = function(lang)
    return #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0
end

local to_install = vim.tbl_filter(not_installed, languages)
if #to_install > 0 then
    ts.install(to_install)
end

local filetypes = {}
for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
        table.insert(filetypes, ft)
    end
end
local ts_start = function(ev)
    pcall(vim.treesitter.start, ev.buf)
end
vim.api.nvim_create_autocmd("FileType", {
    pattern = filetypes,
    callback = ts_start,
})

require("nvim-ts-autotag").setup()

vim.filetype.add({
    pattern = { [".*/%.jjdescription"] = "gitcommit" },
})

require("vim.treesitter.query").add_predicate("is-mise?", function(_, _, bufnr, _)
    local filepath = vim.fs.normalize(vim.api.nvim_buf_get_name(tonumber(bufnr) or 0))
    local filename = vim.fn.fnamemodify(filepath, ":t")
    return filename:match("^%.?mise.*%.toml$") ~= nil
        or filepath:match("/%.?mise/config%.toml$") ~= nil
        or filepath:match("/%.?mise/config%.local%.toml$") ~= nil
        or filepath:match("/%.?mise/config%.[^/]+%.toml$") ~= nil
        or filepath:match("/%.config/mise/mise%.toml$") ~= nil
        or filepath:match("/%.config/mise/mise%.local%.toml$") ~= nil
        or filepath:match("/%.?mise/conf%.d/[^/]+%.toml$") ~= nil
end, { force = true, all = false })
