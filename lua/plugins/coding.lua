return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    opts = {
      check_ts = true,
      ts_config = { java = false },
      map_c_h = true,
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = ([[ [%'%"%)%>%]%)%}%,] ]]):gsub("%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    },
    keys = {
      {
        "<leader>up",
        function()
          local pair = require("nvim-autopairs")
          if pair.state.disabled then
            pair.enable()
            require("notify")("Enabled auto pairs", "info", { title = "Option" })
          else
            pair.disable()
            require("notify")("Disabled auto pairs", "warn", { title = "Option" })
          end
        end,
        desc = "Toggle Auto Pairs",
      },
    },
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = true,
  },

  -- Better text-objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          k = ai.gen_spec.treesitter({ a = { "@block.outer" }, i = { "@block.inner" } }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
          i = ai.gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          o = ai.gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }, {}),
          a = ai.gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }, {}),
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            {
              "%u[%l%d]+%f[^%l%d]",
              "%f[%S][%l%d]+%f[^%l%d]",
              "%f[%P][%l%d]+%f[^%l%d]",
              "^[%l%d]+%f[^%l%d]",
            },
            "^().*()$",
          },
          g = function() -- Whole buffer, similar to `gg` and 'G' motion
            local from = { line = 1, col = 1 }
            local to = {
              line = vim.fn.line("$"),
              col = math.max(vim.fn.getline("$"):len(), 1),
            }
            return { from = from, to = to }
          end,
          u = ai.gen_spec.function_call(), -- u for "Usage"
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)

      require("util.lazy").on_load("which-key.nvim", function()
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ), ], }",
          c = "Class",
          d = "Digit(s)",
          e = "Word in CamelCase & snake_case",
          f = "Function",
          g = "Entire file",
          i = "Conditional",
          k = "Block",
          o = "Loop",
          q = "Quote `, \", '",
          t = "Tag",
          u = "Use/call function & method",
          U = "Use/call without dot in name",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end

        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs({ n = "Next", l = "Last" }) do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register({
          mode = { "o", "x" },
          i = i,
          a = a,
        })
      end)
    end,
  },

  {
    "tpope/vim-rsi",
    event = "VeryLazy",
  },

  {
    "FooSoft/vim-argwrap",
    cmd = "ArgWrap",
    keys = {
      { "<leader>ua", "<cmd>ArgWrap<cr>", desc = "Arg Wrap" },
    },
  },

  {
    "tpope/vim-abolish",
    keys = {
      "crs",
      "crm",
      "crc",
      "crs",
      "cru",
      "cr-",
      "cr.",
      "cr<space>",
      "crt",
    },
  },

  {
    "tommcdo/vim-exchange",
    keys = { { "<C-x>", mode = "x", "<Plug>(Exchange)" } },
    config = function()
      vim.g.exchange_no_mappings = 1
    end,
  },

  {
    "preservim/nerdcommenter",
    keys = {
      { "<leader>c<leader>", desc = "NERDCommenterToggle" },
      { "<leader>c<leader>", mode = "x", desc = "NERDCommenterToggle" },
      { "<leader>cs", mode = "x", desc = "NERDCommenterSexy" },
    },
    config = function()
      -- Add spaces after comment delimiters by default
      vim.g.NERDSpaceDelims = 1

      -- Enable trimming of trailing whitespace when uncommenting
      vim.g.NERDTrimTrailingWhitespace = 1

      -- Specifies the default alignment to use when inserting comments.
      vim.g.NERDDefaultAlign = "left"
    end,
  },

  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    config = true,
  },
}
