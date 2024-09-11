return {
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
          require("window-picker").setup({
            hint = "floating-big-letter",
            selection_chars = "ASDHJKL",
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              bo = {
                filetype = { "neo-tree", "neo-tree-popup", "notify", "noice", "fidget" },
                buftype = { "terminal", "quickfix" },
              },
            },
          })
        end,
      },
    },
    cmd = "Neotree",
    keys = {
      {
        "<leader>e",
        "<cmd>Neotree toggle last<cr>",
        desc = "[E]xplorer NeoTree",
      },
      {
        "<F4>",
        "<cmd>Neotree reveal<cr>",
        desc = "Explorer NeoTree",
      },
    },

    deactivate = function()
      vim.cmd([[Neotree close]])
    end,

    config = function()
      require("neo-tree").setup({
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        source_selector = {
          winbar = true,
          content_layout = "center",
        },

        use_default_mappings = false,
        commands = {
          system_open = function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            if node.type == "directory" then
              vim.fn.jobstart({ "open", path }, { detach = true })
            else
              vim.fn.jobstart({ "open", node:get_parent_id() }, { detach = true })
            end
          end,

          trash = function(state)
            local node = state.tree:get_node()
            if node.type == "message" then
              return
            end

            local path = node.path
            local inputs = require("neo-tree.ui.inputs")
            local _, name = require("neo-tree.utils").split_path(path)
            local msg = string.format("Are you sure you want to trash '%s'?", name)
            inputs.confirm(msg, function(ans)
              if not ans then
                return
              end
              print(path, vim.fn.fnameescape(path))
              vim.fn.system({ "trash", vim.fn.fnameescape(path) })
              require("neo-tree.sources.manager").refresh(state.name)
            end)
          end,

          view = function(state)
            local node = state.tree:get_node()
            if require("neo-tree.utils").is_expandable(node) then
              state.commands["toggle_node"](state)
            else
              state.commands["open"](state)
              vim.cmd("Neotree reveal")
            end
          end,

          diff_files = function(state)
            local node = state.tree:get_node()
            local log = require("neo-tree.log")
            state.clipboard = state.clipboard or {}
            if diff_Node and diff_Node ~= tostring(node.id) then
              local current_Diff = node.id
              require("neo-tree.utils").open_file(state, diff_Node, open)
              vim.cmd("vert diffs " .. current_Diff)
              log.info("Diffing " .. diff_Name .. " against " .. node.name)
              diff_Node = nil
              current_Diff = nil
              state.clipboard = {}
              require("neo-tree.ui.renderer").redraw(state)
            else
              local existing = state.clipboard[node.id]
              if existing and existing.action == "diff" then
                state.clipboard[node.id] = nil
                diff_Node = nil
                require("neo-tree.ui.renderer").redraw(state)
              else
                state.clipboard[node.id] = { action = "diff", node = node }
                diff_Name = state.clipboard[node.id].node.name
                diff_Node = tostring(state.clipboard[node.id].node.id)
                log.info("Diff source file " .. diff_Name)
                require("neo-tree.ui.renderer").redraw(state)
              end
            end
          end,

          copy_filepath = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local vals = {
              ["BASENAME"] = modify(filename, ":r"),
              ["EXTENSION"] = modify(filename, ":e"),
              ["FILENAME"] = filename,
              ["PATH (CWD)"] = modify(filepath, ":."),
              ["PATH (HOME)"] = modify(filepath, ":~"),
              ["PATH"] = filepath,
              ["URI"] = vim.uri_from_fname(filepath),
            }

            local options = vim.tbl_filter(function(val)
              return vals[val] ~= ""
            end, vim.tbl_keys(vals))
            if vim.tbl_isempty(options) then
              vim.notify("No values to copy", vim.log.levels.WARN)
              return
            end
            table.sort(options)
            vim.ui.select(options, {
              prompt = "Choose to copy to clipboard:",
              format_item = function(item)
                return ("%s: %s"):format(item, vals[item])
              end,
            }, function(choice)
              local result = vals[choice]
              if result then
                vim.notify(("Copied: `%s`"):format(result))
                vim.fn.setreg("+", result)
              end
            end)
          end,

          open_all_subnodes = function(state)
            local node = state.tree:get_node()
            local fCommands = require("neo-tree.sources.filesystem.commands")
            fCommands.expand_all_nodes(state, node)
          end,
        },

        window = {
          mappings = {
            ["<esc>"] = "cancel",

            ["<cr>"] = "open",
            ["o"] = "open_with_window_picker",
            ["<leader>o"] = "system_open",
            ["<tab>"] = "view",
            ["<c-s>"] = "split_with_window_picker",
            ["<c-v>"] = "vsplit_with_window_picker",
            ["<c-t>"] = "open_tabnew",
            ["O"] = "open_all_subnodes",

            ["x"] = "close_node",
            ["X"] = "close_all_subnodes",

            ["p"] = { "toggle_preview", config = { use_float = true, use_image_nvim = true } },
            ["P"] = "focus_preview",

            ["<leader>c"] = "cut_to_clipboard",
            ["<leader>p"] = "paste_from_clipboard",
            ["c"] = "copy_to_clipboard",
            ["y"] = "copy_filepath",
            ["r"] = "rename",
            ["m"] = { "move", config = { show_path = "relative" } },
            ["<c-r>"] = "refresh",
            ["a"] = { "add", config = { show_path = "relative" } },
            ["dd"] = "trash",

            ["<C-a>"] = "toggle_auto_expand_width",
            ["q"] = "close_window",
            ["?"] = "show_help",
            ["[s"] = "prev_source",
            ["]s"] = "next_source",
            ["i"] = "show_file_details",

            ["<leader>d"] = "diff_files",
          },
        },

        filesystem = {
          use_libuv_file_watcher = vim.fn.has("win32") ~= 1,
          window = {
            mappings = {
              ["u"] = "navigate_up",
              ["C"] = "set_root",

              ["H"] = "toggle_hidden",
              ["/"] = "fuzzy_finder",
              ["D"] = "fuzzy_finder_directory",
              ["#"] = "fuzzy_sorter",
              ["f"] = "filter_on_submit",
              ["<C-x>"] = "clear_filter",
              ["[g"] = "prev_git_modified",
              ["]g"] = "next_git_modified",
            },
            fuzzy_finder_mappings = {
              ["<down>"] = "move_cursor_down",
              ["<C-n>"] = "move_cursor_down",
              ["<up>"] = "move_cursor_up",
              ["<C-p>"] = "move_cursor_up",
            },
          },
        },

        buffers = {
          window = {
            ["u"] = "navigate_up",
            ["C"] = "set_root",
            ["<leader>x"] = "buffer_delete",
            ["i"] = "show_file_details",
          },
        },

        filtered_items = {
          hide_by_name = {
            ".DS_Store",
            "thumbs.db",
            "node_modules",
            "vendor",
          },

          always_show = {
            ".gitignore",
          },
        },
      })
    end,
  },

  {
    "echasnovski/mini.files",
    version = "*",
    keys = {
      { "<leader>E", "<cmd>lua MiniFiles.open()<cr>", desc = "MiniFiles [E]xplorer" },
    },
    config = true,
  },

  -- search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    build = false,
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = {
      {
        "<leader>rs",
        function()
          require("spectre").open()
        end,
        desc = "Replace in Files (Spectre)",
      },
    },
  },

  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({
        git = {
          bcommits = {
            actions = {
              -- refer: https://github.com/ibhagwan/fzf-lua/issues/476
              ["ctrl-v"] = function(...)
                require("fzf-lua.actions").git_buf_vsplit(...)
                vim.cmd([[windo diffthis]])
              end,
            },
          },
        },
      })
    end,
    keys = function()
      local findGitFilesIfInGit = function(query)
        local util = require("util.git")
        local cwd = util.git_root() or vim.uv.cwd()
        local opts = {
          cwd = cwd,
          fzf_cli_args = ('--header="cwd = %s"'):format(vim.fn.shellescape(cwd)),
          query = query,
          formatter = "path.filename_first",
        }

        if util.is_in_git() then
          require("fzf-lua").git_files(opts)
        else
          require("fzf-lua").files(opts)
        end
      end

      return {
        { "<leader>sb", "<cmd>FzfLua buffers<cr>", desc = "Switch Buffer" },
        { "<leader>sB", "<cmd>FzfLua blines<cr>", desc = "Grep current buffer lines" },
        { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "Grep" },
        { "<leader>sG", "<cmd>FzfLua grep_cword<cr>", desc = "Grep <cword>" },
        { "<leader>sg", mode = { "x" }, "<cmd>FzfLua grep_visual<cr>", desc = "Grep with Visual Selection" },
        {
          "<leader>sf",
          function()
            findGitFilesIfInGit(nil)
          end,
          desc = "Find (Git) Files",
        },
        {
          "<leader>sF",
          function()
            findGitFilesIfInGit(vim.fn.expand("<cword>"))
          end,
          desc = "Find (Git) Files with <cword>",
        },
        {
          "<leader>sf",
          mode = { "x" },
          function()
            findGitFilesIfInGit(require("fzf-lua.utils").get_visual_selection())
          end,
          desc = "Find (Git) Files with Visual Selection",
        },
        {
          "<leader>sr",
          function()
            local util = require("util.git")
            local cwd = util.git_root() or vim.uv.cwd()
            local opts = {
              cwd = cwd,
              fzf_cli_args = ('--header="cwd = %s"'):format(vim.fn.shellescape(cwd)),
            }
            require("fzf-lua").oldfiles(opts)
          end,
          desc = "Opened Files History",
        },
        { "<leader>sR", "<cmd>FzfLua resume<cr>", desc = "Resume last command/query" },
        { "<leader>s:", "<cmd>FzfLua command_history<cr>", desc = "Command history" },
        { "<leader>s/", "<cmd>FzfLua search_history<cr>", desc = "Search history" },
        { "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "neovim commands" },
        { "<leader>sC", "<cmd>FzfLua colorschemes<cr>", desc = "color schemes" },
        { "<leader>ss", "<cmd>FzfLua git_status<cr>", desc = "git status" },
        { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "key mappings" },
        { "<leader>sm", "<cmd>FzfLua manpages<cr>", desc = "man pages" },
        { "<leader>ld", "<cmd>FzfLua lsp_document_diagnostics<cr>", desc = "[D]ocument [D]iagnostics" },
        { "<leader>lD", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "[W]orkspace [D]iagnostics" },
      }
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts_extend = { "spec" },
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>c", group = "comment" },
          { "<leader>F", group = "file" },
          { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
          { "<leader>s", group = "search" },
          { "<leader>r", group = "replace" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "git hunks" },
          { "<leader>l", group = "lsp" },
          { "<leader>t", group = "trouble" },
          { "z", group = "fold" },
          { "[", group = "prev" },
          { "]", group = "next" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          -- better descriptions
          { "gx", desc = "Open with system app" },
        },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show({ keys = "<c-w>", loop = true })
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },

  {
    "tpope/vim-fugitive",
    cmd = { "G", "Git" },
    keys = {
      { "<leader>gs", "<cmd>tab Git<cr>", desc = "Git Status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git Blame" },
      { "<leader>gc", "<cmd>Git commit<cr>", desc = "Git Commit" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy",
    opts = {
      signs = {
        delete = { text = "↳" },
        topdelete = { text = "↱" },
      },

      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- Navigation
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        -- Actions
        map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk")
        map("v", "<leader>ghr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk Inline")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        map("n", "<leader>gtb", gs.toggle_current_line_blame, "Toggle Line Blame")
        map("n", "<leader>gtn", gs.toggle_numhl, "Toggle Numhl")
        map("n", "<leader>gtd", gs.toggle_deleted, "Toggle Deleted")

        -- Text object
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  {
    "AndrewRadev/linediff.vim",
    cmd = { "Linediff", "LinediffAdd", "LinediffReset" },
    keys = {
      { "<leader>ul", mode = "v", ":Linediff<cr>", desc = "Line Diff" },
    },
  },

  -- buffer remove
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>x",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      {
        "<leader>X",
        function()
          require("mini.bufremove").delete(0, true)
        end,
        desc = "Delete Buffer (Force)",
      },
    },
  },

  {
    "kevinhwang91/nvim-bqf",
    dependencies = { "junegunn/fzf" },
    ft = "qf",
  },
}
