local map = function(mode, l, r, opts)
  opts = opts or {}
  vim.keymap.set(mode, l, r, opts)
end

local merge = function(desc, opt)
  opt = opt or {}
  if type(desc) == "string" then
    opt.desc = desc
  end

  return opt
end

local silent_opts = function(desc, opt)
  return vim.tbl_deep_extend("force", { silent = true }, merge(desc, opt))
end

local opts = function(desc, opt)
  return vim.tbl_deep_extend("force", { noremap = true, silent = true }, merge(desc, opt))
end

-- Easily save, quit
map("n", "<leader>w", "<cmd>w<cr>", opts("[W]rite"))
map("n", "<leader>q", "<cmd>q<cr>", opts("[Q]uit"))
map("n", "<leader>Q", "<cmd>qa<cr>", opts("[Q]uit All"))

-- Easily Jump to First/Last Non-Blank Character
map("v", "gh", "^", opts("Jump to First Non-Blank Character"))
map("v", "gl", "g_", opts("Jump to Last Non-Blank Character"))

-- Force myself to use <C-[> in insert mode
map("i", "<C-c>", "<Nop>", opts("Pls Use <C-[>"))

-- Using <c-p>/<c-n> as Up/Down in Insert Mode
local function warn(msg)
  return function()
    vim.notify(msg, vim.log.levels.WARN)
  end
end
map("i", "<C-k>", warn("Pls Use <C-p>"), opts("Pls Use <C-p>"))
map("i", "<C-j>", warn("Pls Use <C-n>"), opts("Pls Use <C-n>"))

-- Focus the current split: https://www.reddit.com/r/vim/comments/5civsq/is_there_a_way_to_focus_the_current_split/
map("n", "<leader>z", "<cmd>tab split<cr>", opts("Focus the Current Split"))

-- Yarn to system, Paste from system
map("v", "<leader>y", '"+y', opts("Yarn to System"))
map("n", "<leader>p", '"+p', opts("[P]aste from System"))
map("v", "<leader>p", '"+p', opts("[P]aste from System"))

-- Better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", opts("Better j", { expr = true }))
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", opts("Better k", { expr = true }))

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", opts("Go to Left Window"))
map("n", "<C-j>", "<C-w>j", opts("Go to Lower Window"))
map("n", "<C-k>", "<C-w>k", opts("Go to Upper Window"))
map("n", "<C-l>", "<C-w>l", opts("Go to Right Window"))

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", opts("Increase Window Height"))
map("n", "<C-Down>", "<cmd>resize -2<cr>", opts("Decrease Window Height"))
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", opts("Decrease Window Width"))
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", opts("Increase Window Width"))

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", opts("Move Down"))
map("n", "<A-k>", "<cmd>m .-2<cr>==", opts("Move Up"))
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", opts("Move Down"))
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", opts("Move Up"))
map("v", "<A-j>", ":m '>+1<cr>gv=gv", opts("Move Down"))
map("v", "<A-k>", ":m '<-2<cr>gv=gv", opts("Move Up"))

-- Search {{{
-- Keep Behavior of n and N
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- Bring search results to midscreen
-- https://www.reddit.com/r/vim/comments/oyqkkd/your_most_frequently_used_mapping/
map("n", "n", "'Nn'[v:searchforward].'zzzv'", opts("Next Search Result", { expr = true }))
map("x", "n", "'Nn'[v:searchforward]", opts("Next Search Result", { expr = true }))
map("o", "n", "'Nn'[v:searchforward]", opts("Next Search Result", { expr = true }))
map("n", "N", "'nN'[v:searchforward].'zzzv'", opts("Prev Search Result", { expr = true }))
map("x", "N", "'nN'[v:searchforward]", opts("Prev Search Result", { expr = true }))
map("o", "N", "'nN'[v:searchforward]", opts("Prev Search Result", { expr = true }))

-- Search for visually selected text: https://vim.fandom.com/wiki/Search_for_visually_selected_text
-- map("v", "*", "y/\\V<C-R>=escape(@\",'/\\')<cr><cr>", opts("Search for Visually Selected"))

-- Search within Visual Selection: https://www.reddit.com/r/neovim/comments/zy3qq0/til_search_within_visual_selection/
map("x", "/", "<Esc>/\\%V", opts("Search within Visual Selection"))
map("x", "?", "<Esc>?\\%V", opts("Search within Visual Selection"))

-- Search current word: https://vim.fandom.com/wiki/Searching#Case_sensitivity
map("n", "*", "/\\<<C-R>=expand('<cword>')<cr>\\><cr>", opts("Search Current <cword>"))

-- Highlight matches without moving: https://vim.fandom.com/wiki/Highlight_all_search_pattern_matches#Highlight_matches_without_moving
map("n", "z/", ":let @/='\\<<C-R>=expand(\"<cword>\")<cr>\\>'<cr>:set hls<cr>", opts("Highlight Current word"))
-- }}} Search

-- Better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Buffer
map("n", "[b", "<cmd>bprevious<cr>", opts("Prev Buffer"))
map("n", "]b", "<cmd>bnext<cr>", opts("Next Buffer"))

-- New file
map("n", "<leader>Fn", "<cmd>new<cr>", opts("New File in Split Window"))
map("n", "<leader>FN", "<cmd>enew<cr>", opts("New File in Current Window"))

-- Easily Navigation Quickfix
map("n", "[q", vim.cmd.cprev, opts("Previous Quickfix"))
map("n", "]q", vim.cmd.cnext, opts("Next Quickfix"))

-- Easily switch tab
map("n", "<C-n>", "gt", opts("Next Tab"))
map("n", "<C-p>", "gT", opts("Previous Tab"))

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Clear search
map("n", "<leader><BS>", "<cmd>noh<cr>", opts("Clear hlsearch"))

-- Keywordprg
map("n", "K", "<cmd>norm! K<cr>", silent_opts("Keywordprg"))

-- <leader>u {{{
-- Toggle Option
map("n", "<leader>us", "<cmd>set spell!<cr>", opts("Toggle Spelling"))
map("n", "<leader>uw", "<cmd>set wrap!<cr>", opts("Toggle Word Wrap"))
map("n", "<leader>ul", "<cmd>set number!<cr>", opts("Toggle Line Numbers"))
map("n", "<leader>uL", "<cmd>set relativenumber!<cr>", opts("Toggle Relative Line Numbers"))
map("n", "<leader>up", "<cmd>set paste!<cr>", opts("Toggle Paste Mode"))

-- Inspect Highlights under cursor
map("n", "<leader>ui", vim.show_pos, opts("Inspect Pos"))
map("n", "<leader>uI", "<cmd>InspectTree<cr>", opts("Inspect Tree"))

-- Clear search, diff update and redraw
-- Taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><cr>",
  opts("Redraw / Clear HlSearch / Diff Update")
)

map("n", "<leader>ut", function()
  if vim.b.ts_highlight then
    vim.treesitter.stop()
  else
    vim.treesitter.start()
  end
end, opts("Toggle Treesitter Highlight"))

local function toggleDiagnostic(bufnr)
  ---@type vim.diagnostic.Filter
  local filter = { bufnr = bufnr }
  return function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled(filter), filter)
  end
end

map("n", "<leader>ud", toggleDiagnostic(0), opts("Toggle Buffer Diagnostic"))
map("n", "<leader>uD", toggleDiagnostic(nil), opts("Toggle Diagnostic"))
-- }}} <leader>u

-- Do NOT rewrite register after paste: https://vim.fandom.com/wiki/Replace_a_word_with_yanked_text#Alternative_mapping_for_paste
map("v", "p", 'p:let @"=@0<cr>', opts())
map("v", "P", 'P:let @"=@0<cr>', opts())

-- reference: https://www.reddit.com/r/vim/comments/ksix5c/replacing_text_my_favorite_remap/
map(
  "n",
  "<leader>rw",
  ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gc<Left><Left><Left>",
  { noremap = true, desc = "Replace the <cword> Under Cursor" }
)

-- Quickly add empty lines: https://github.com/mhinz/vim-galore#quickly-add-empty-lines
map("n", "<leader>o", ":<C-u>put =repeat(nr2char(10), v:count1)<cr>", opts("Add New Line Below the Current Line"))
map("n", "<leader>O", ":<C-u>put! =repeat(nr2char(10), v:count1)<cr>'[", opts("Add New Line Above the Current Line"))

-- Start Insert mode when press <C-h> in Select mode, ref: coc-snippets
map("s", "<C-h>", "<C-g>c", opts("Delete Selected Text"))

return {
  silent_opts = silent_opts,
  opts = opts,
}
