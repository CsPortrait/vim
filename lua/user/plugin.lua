local fn = vim.fn

local packer_install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

if fn.empty(fn.glob(packer_install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		packer_install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
    augroup packer_user_config
        autocmd!
        autocmd BufWritePost plugin.lua source <afile> | PackerSync
    augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup(function(use)
	-- impatient needs to be setup before any other lua plugin is loaded
	use({
		"lewis6991/impatient.nvim",
		config = function()
			require("impatient").enable_profile()
		end,
	})

	use("wbthomason/packer.nvim")
	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")

	-- colorscheme
	use({ "sainnhe/everforest" })

	use({ "moll/vim-bbye", cmd = "Bdelete" })
	use({ "AndrewRadev/linediff.vim", cmd = "Linediff" })
	use({ "ojroques/vim-oscyank", event = "TextYankPost", config = [[require('user.oscyank')]] })
	use({ "FooSoft/vim-argwrap", cmd = "ArgWrap" })
	use({ "mbbill/undotree", cmd = "UndotreeToggle" })
	use({ "dstein64/vim-startuptime", cmd = "StartupTime", config = [[vim.g.startuptime_tries = 10]] })
	use({ "machakann/vim-swap", keys = { "gs" } })
	use({
		"kkoomen/vim-doge",
		run = ":call doge#install()",
		cmd = "DogeGenerate",
		config = [[vim.g.doge_enable_mappings = 0]],
	})
	use({ "tpope/vim-fugitive", cmd = { "G", "Git", "Gwrite", "Gread" } })
	use({ "vim-test/vim-test", cmd = { "TestFile", "TestNearest" }, config = [[require("user.test")]] })
	use({ "tpope/vim-abolish", keys = { "crs", "crm", "crc", "crs", "cru", "cr-", "cr.", "cr<space>", "crt" } })
	use({ "hotoo/pangu.vim", cmd = { "Pangu" } })
	use({ "bootleq/vim-cycle", keys = { "<C-a>", "<C-v>" }, config = [[require("user.cycle")]] })
	use({ "tommcdo/vim-exchange", keys = { { "x", "<C-x>" } }, config = [[require("user.exchange")]] })
	use({ "junegunn/vim-easy-align", keys = { { "v", "ga" } }, config = [[require("user.easy-align")]] })
	use({
		"preservim/nerdcommenter",
		keys = { { "n", "<leader>c<leader>" }, { "x", "<leader>c<leader>" }, { "x", "<leader>cs" } },
		config = [[require('user.comment')]],
	})
	use({ "mzlogin/vim-markdown-toc", cmd = { "GenTocGFM", "GenTocGitLab", "GenTocMarked" } })
	use({ "plasticboy/vim-markdown", ft = { "markdown" } })
	use({
		"lukas-reineke/headlines.nvim",
		ft = { "markdown", "rmd", "vimwiki" },
		config = function()
			require("headlines").setup()
		end,
	})
	-- TODO: lazy load markdown-preview with cmd instead ft, issues: https://github.com/wbthomason/packer.nvim/issues/620
	use({ "iamcco/markdown-preview.nvim", run = "cd app && yarn install", ft = { "markdown" } })

	use({ "tpope/vim-rsi", event = "VimEnter" })
	use({ "tpope/vim-repeat", event = "VimEnter" })
	use({ "machakann/vim-sandwich", event = "VimEnter" })
	use({ "andymass/vim-matchup", event = "VimEnter" })
	use({ "gelguy/wilder.nvim", run = ":UpdateRemotePlugins", config = [[require("user.wilder")]] })

	use("kyazdani42/nvim-web-devicons")
	use("kyazdani42/nvim-tree.lua")
	use("lukas-reineke/indent-blankline.nvim")
	use("goolord/alpha-nvim")
	use("nvim-lualine/lualine.nvim")
	use("akinsho/bufferline.nvim")
	use("akinsho/toggleterm.nvim")
	use("folke/which-key.nvim")
	use("karb94/neoscroll.nvim")
	use("kevinhwang91/nvim-bqf")
	use("kevinhwang91/nvim-hlslens")
	use("lewis6991/gitsigns.nvim")

	-- snippets engine
	use("L3MON4D3/LuaSnip")
	use({ "rafamadriz/friendly-snippets", after = "LuaSnip" })

	-- cmp plugins
	use({ "hrsh7th/nvim-cmp", after = "LuaSnip", config = [[require("user.cmp")]] })
	use({ "hrsh7th/cmp-nvim-lsp", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
	use({ "saadparwaiz1/cmp_luasnip", after = "nvim-cmp" })

	use({ "windwp/nvim-autopairs", after = "nvim-cmp", config = [[require("user.autopairs")]] })

	-- lsp
	use({ "williamboman/nvim-lsp-installer" })
	use({ "jose-elias-alvarez/null-ls.nvim" })
	use({ "ray-x/lsp_signature.nvim" })
	use({
		"neovim/nvim-lspconfig",
		after = { "cmp-nvim-lsp" },
		config = [[require("user.lsp")]],
	})

	use({ "nvim-telescope/telescope.nvim", cmd = "Telescope", config = [[require("user.telescope")]] })

	-- treesitter
	use({ "nvim-treesitter/nvim-treesitter-textobjects" })
	use({ "p00f/nvim-ts-rainbow" })
	use({
		"nvim-treesitter/nvim-treesitter",
		requires = { { "nvim-lua/plenary.nvim" } },
		run = ":TSUpdate",
		config = [[require("user.treesitter")]],
	})

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
