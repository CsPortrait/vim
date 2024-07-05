return function(event)
  local map = function(keys, func, desc)
    vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
  end

  map("gd", "<cmd>FzfLua lsp_definitions<cr>", "[G]oto [D]efinition")
  map("gD", "<cmd>FzfLua lsp_declarations<cr>", "[G]oto [D]eclaration")
  map("gI", "<cmd>FzfLua lsp_implementations<cr>", "[G]oto [I]mplementation")
  map("gy", "<cmd>FzfLua lsp_typedefs<cr>", "[G]oto T[y]pe Definition")
  map("gr", "<cmd>FzfLua lsp_references<cr>", "[G]oto [R]eferences")
  map("gk", vim.lsp.buf.signature_help, "Signature help")

  map("<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", "Document [S]ymbols")
  map("<leader>lS", "<cmd>FzfLua lsp_workspace_symbols<cr>", "Workspace [S]ymbols")
  map("<leader>la", "<cmd>FzfLua lsp_code_actions<cr>", "[C]ode [A]ction")
  map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

  local client = vim.lsp.get_client_by_id(event.data.client_id)
  if client and client.server_capabilities.documentHighlightProvider then
    local highlight_augroup = vim.api.nvim_create_augroup("cs_lsp_highlight", { clear = false })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.document_highlight,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      buffer = event.buf,
      group = highlight_augroup,
      callback = vim.lsp.buf.clear_references,
    })

    vim.api.nvim_create_autocmd("LspDetach", {
      group = vim.api.nvim_create_augroup("cs_lsp_detach", { clear = true }),
      callback = function(event2)
        vim.lsp.buf.clear_references()
        vim.api.nvim_clear_autocmds({ group = "cs_lsp_highlight", buffer = event2.buf })
      end,
    })
  end

  if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })

    map("<leader>lh", function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
    end, "[T]oggle Inlay [H]ints")
  end
end
