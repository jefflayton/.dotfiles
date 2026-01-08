vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Write Buffer" })
vim.keymap.set("n", "<leader>x", ":x<cr>", { desc = "Write and Close Buffer" })
vim.keymap.set("n", "<leader>q", ":q<cr>", { desc = "Close Buffer" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape Terminal" })

-- System Clipboard
vim.keymap.set({ "n", "v", "x" }, "<leader>y", '"+y<cr>', { desc = "Yank to System" })
vim.keymap.set({ "n", "v", "x" }, "<leader>d", '"+d<cr>', { desc = "Delete to System" })

-- Move Lines
vim.keymap.set("n", "<M-k>", ":m .-2<cr>==", { desc = "Move Line Up" })
vim.keymap.set("n", "<M-j>", ":m .+1<cr>==", { desc = "Move Line Down" })
vim.keymap.set("v", "<M-j>", ":m '>+1<cr>gv=gv", { desc = "Move Line Up" })
vim.keymap.set("v", "<M-k>", ":m '<-2<cr>gv=gv", { desc = "Move Line Down" })
vim.keymap.set("v", "<M-l>", ">gv", { desc = "Move Line Left" })
vim.keymap.set("v", "<M-h>", "<gv", { desc = "Move Line Right" })

-- Insert Newlines in Normal Mode
vim.keymap.set("n", "<cr>", "m`o<esc>`")
vim.keymap.set("n", "<s-cr>", "m`O<esc>`")

-- Splits
vim.keymap.set("n", "<c-h>", ":wincmd h<cr>", { desc = "Split: Right" })
vim.keymap.set("n", "<c-j>", ":wincmd j<cr>", { desc = "Split: Down" })
vim.keymap.set("n", "<c-k>", ":wincmd k<cr>", { desc = "Split: Up" })
vim.keymap.set("n", "<c-l>", ":wincmd l<cr>", { desc = "Split: Left" })

-- Tabs
vim.keymap.set("n", "<c-t>k", ":tabnew<cr>", { desc = "Tab: New" })
vim.keymap.set("n", "<c-t>j", ":tabclose<cr>", { desc = "Tab: Close" })
vim.keymap.set("n", "<c-t>J", ":tabonly<cr>", { desc = "Tab: Close all except curent one" })
vim.keymap.set("n", "<c-t>l", ":+tabnext<cr>", { desc = "Tab: Next" })
vim.keymap.set("n", "<c-t>h", ":-tabnext<cr>", { desc = "Tab: Previous" })
vim.keymap.set("n", "<c-t>L", ":+tabmove<cr>", { desc = "Tab: Move Right" })
vim.keymap.set("n", "<c-t>H", ":-tabmove<cr>", { desc = "Tab: Move Left" })
