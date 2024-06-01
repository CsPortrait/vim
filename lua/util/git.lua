local M = {}

M.is_in_git = function()
  vim.fn.system("git rev-parse --is-inside-work-tree")

  return vim.v.shell_error == 0
end

M.git_root = function(cwd)
  local cmd = { "git", "rev-parse", "--show-toplevel" }
  if cwd then
    table.insert(cmd, 2, "-C")
    table.insert(cmd, 3, vim.fn.expand(cwd))
  end

  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end

  return output[1]
end

return M
