if vim.b.cs_ftplugin == 1 then
  return
end

vim.b.cs_ftplugin = 1

vim.opt_local.expandtab = false

vim.b.argwrap_tail_comma = 1
