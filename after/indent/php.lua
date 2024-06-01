if vim.b.cs_after == 1 then
  return
end

vim.b.cs_after = 1

-- Refer: https://jdhao.github.io/2022/12/02/nvim-override-default-options/
vim.opt_local.smartindent = true
vim.opt_local.indentexpr = ""
