if vim.b.cs_ftplugin == 1 then
  return
end

vim.b.cs_ftplugin = 1

vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

vim.b.argwrap_tail_comma = 1
