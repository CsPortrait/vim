local telescope = require("telescope")

local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local action_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")

-- Refer: https://github.com/nvim-telescope/telescope.nvim/issues/1048
local function open_on_tab(prompt_bufnr)
	local picker = action_state.get_current_picker(prompt_bufnr)
	local num_selections = #picker:get_multi_selection()
	local copen = true
	if not num_selections or num_selections <= 1 then
		actions.add_selection(prompt_bufnr)
		copen = false
	end

	if copen then
		actions.send_selected_to_qflist(prompt_bufnr)
		vim.cmd("tabnew")
		vim.cmd("copen")
		vim.cmd("cc")
	else
		actions.select_tab(prompt_bufnr)
	end
end

-- Refer: https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#ignore-files-bigger-than-a-threshold
local buffer_previewer_maker = function(filepath, bufnr, opts)
	opts = opts or {}

	filepath = vim.fn.expand(filepath)
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then
			return
		end
		if stat.size > 100000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end

telescope.setup({
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		path_display = { "smart" },

		mappings = {
			i = {
				["<esc>"] = actions.close,
				["<C-w>"] = function()
					vim.api.nvim_input("<c-s-w>")
				end,
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-c>"] = actions.close,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,

				["<CR>"] = actions.select_default,
				["<C-s>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = open_on_tab,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["<C-g>"] = actions.toggle_all,
				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

				["<C-_>"] = actions.which_key,
				["<M-p>"] = action_layout.toggle_preview,
			},

			n = {
				["<esc>"] = actions.close,
				["<CR>"] = actions.select_default,
				["<C-s>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = open_on_tab,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,
				["gg"] = actions.move_to_top,
				["G"] = actions.move_to_bottom,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["?"] = actions.which_key,
			},
		},

		-- https://github.com/nvim-telescope/telescope.nvim/wiki/Configuration-Recipes#ripgrep-remove-indentation
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--trim",
		},

		buffer_previewer_maker = buffer_previewer_maker,
	},
	pickers = {
		find_files = { theme = "ivy" },
		git_files = { theme = "ivy" },
		live_grep = { theme = "ivy" },
		buffers = { theme = "ivy" },
		oldfiles = { theme = "ivy" },
		keymaps = { theme = "ivy" },
		git_status = { theme = "ivy" },
		commands = { theme = "ivy" },
		command_history = { theme = "ivy" },
		help_tags = { theme = "ivy" },
		man_pages = { theme = "ivy" },
		registers = { theme = "ivy" },
		jumplist = { theme = "ivy" },
		current_buffer_fuzzy_find = { theme = "ivy", previewer = false },
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})
