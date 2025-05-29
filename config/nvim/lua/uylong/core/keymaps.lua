vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>=", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement
-- window management
keymap.set("n", "<leader>wv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>wx", "<C-w>c", { desc = "Close current split" }) -- close current split window
keymap.set("n", "<leader>wX", "<C-w>o", { desc = "Close Close all windows except current" }) -- close current split window
keymap.set("n", "<leader>wr", "<C-w>r", { desc = "Rotate window" }) -- close current split window
keymap.set("n", "<leader>wn", "<C-w>T", { desc = "Move current window to a new tab" })

keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tX", "<cmd>tabonly<CR>", { desc = "Close all other tabs" })
keymap.set("n", "<leader>t2", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>t1", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab
-- Save file with Ctrl+S in normal and insert modes
keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file in insert mode" })
-- quit Neovim with Leader q
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit Neovim" })
-- Map
keymap.set("n", "<leader>?", "<cmd>map<CR>", { desc = "Show all keymaps" })

-- Define the toggle function
local term_buf = nil

local function toggle_terminal()
  -- If we have a valid terminal buffer…
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    -- …and it’s shown in some window, close that window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == term_buf then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
    -- Otherwise buffer exists but isn’t visible → fall through to re-open
  end

  -- If buffer exists, just open it; else create a new terminal buffer
  if term_buf then
    vim.cmd("botright split") -- bottom split
    vim.cmd("resize 10") -- make it 10 lines high
    vim.api.nvim_set_current_buf(term_buf)
  else
    vim.cmd("botright split") -- bottom split
    vim.cmd("resize 10") -- make it 10 lines high
    vim.cmd("terminal") -- start a new terminal
    term_buf = vim.api.nvim_get_current_buf()
  end

  -- Enter insert mode in the terminal
  vim.cmd("startinsert")
end

-- Map <C-`> in normal mode
vim.keymap.set("n", "<C-`>", toggle_terminal, {
  desc = "Toggle bottom terminal and enter insert mode",
})

-- In insert mode, first exit insert then toggle
vim.keymap.set("t", "<C-`>", function()
  -- send the <C-\><C-n> to exit terminal mode
  local esc = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
  vim.api.nvim_feedkeys(esc, "n", false)
  -- now toggle the window
  toggle_terminal()
end, {
  desc = "Toggle bottom terminal (from terminal mode)",
})
-- Execute Lua code in visual mode
vim.keymap.set("v", "<leader>x", function()
  local code = table.concat(vim.fn.getline("v", "."), "\n")
  load(code)()
end, { desc = "Execute selected Lua code" })
