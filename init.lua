vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 10
vim.opt.termguicolors = true

-- Bootstrap Lazy Vim package manger
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Load Lazy Vim
require("lazy").setup({
	-- Set theme
	{
		"catppuccin/nvim",
		as = "catppuccin",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato", -- latte, frappe, macchiato, mocha
				background = { -- :h background
					light = "latte",
					dark = "mocha",
				},
				transparent_background = false, -- disables setting the background color.
				show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
				term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
				dim_inactive = {
					enabled = false, -- dims the background color of inactive window
					shade = "dark",
					percentage = 0.15, -- percentage of the shade to apply to the inactive window
				},
				no_italic = false, -- Force no italic
				no_bold = false, -- Force no bold
				no_underline = false, -- Force no underline
				styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
					comments = { "italic" }, -- Change the style of comments
					conditionals = { "italic" },
					loops = {},
					functions = {},
					keywords = {},
					strings = {},
					variables = {},
					numbers = {},
					booleans = {},
					properties = {},
					types = {},
					operators = {},
					-- miscs = {}, -- Uncomment to turn off hard-coded styles
				},
				color_overrides = {},
				custom_highlights = {},
				default_integrations = true,
				integrations = {
					cmp = true,
					gitsigns = true,
					nvimtree = true,
					treesitter = true,
					notify = false,
					mini = {
						enabled = true,
						indentscope_color = "",
					},
					-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
				},
			})

			-- setup must be called before loading
			vim.cmd.colorscheme "catppuccin"
		end,
	},

	{             -- Useful plugin to show you pending keybinds.
		'folke/which-key.nvim',
		event = 'VimEnter', -- Sets the loading event to 'VimEnter'
		config = function() -- This is the function that runs, AFTER loading
			require('which-key').setup()

			-- Document existing key chains
			require('which-key').add {
				{ '<leader>a', group = '[A]ctions' },
				{ '<leader>c', group = '[C]ode' },
				{ '<leader>d', group = '[D]ocument' },
				{ '<leader>r', group = '[R]ename' },
				{ '<leader>s', group = '[S]earch' },
				{ '<leader>w', group = '[W]orkspace' },
				{ '<leader>t', group = '[T]oggle' },
				{ '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
			}
		end,
	},
	{
		"windwp/nvim-ts-autotag"
	},
	-- NOTE: Telescope for fast and comfortable fuzzy searching
	{ -- Fuzzy Finder (files, lsp, etc)
		'nvim-telescope/telescope.nvim',
		event = 'VimEnter',
		branch = '0.1.x',
		dependencies = {
			'nvim-lua/plenary.nvim',
			{ -- If encountering errors, see telescope-fzf-native README for installation instructions
				'nvim-telescope/telescope-fzf-native.nvim',

				-- `build` is used to run some command when the plugin is installed/updated.
				-- This is only run then, not every time Neovim starts up.
				build = 'make',

				-- `cond` is a condition used to determine whether this plugin should be
				-- installed and loaded.
				cond = function()
					return vim.fn.executable 'make' == 1
				end,
			},
			{ 'nvim-telescope/telescope-ui-select.nvim' },

			-- Useful for getting pretty icons, but requires a Nerd Font.
			{ 'nvim-tree/nvim-web-devicons',            enabled = vim.g.have_nerd_font },
		},
		config = function()
			-- Telescope is a fuzzy finder that comes with a lot of different things that
			-- it can fuzzy find! It's more than just a "file finder", it can search
			-- many different aspects of Neovim, your workspace, LSP, and more!
			--
			-- The easiest way to use Telescope, is to start by doing something like:
			--  :Telescope help_tags
			--
			-- After running this command, a window will open up and you're able to
			-- type in the prompt window. You'll see a list of `help_tags` options and
			-- a corresponding preview of the help.
			--
			-- Two important keymaps to use while in Telescope are:
			--  - Insert mode: <c-/>
			--  - Normal mode: ?
			--
			-- This opens a window that shows you all of the keymaps for the current
			-- Telescope picker. This is really useful to discover what Telescope can
			-- do as well as how to actually do it!

			-- [[ Configure Telescope ]]
			-- See `:help telescope` and `:help telescope.setup()`
			require('telescope').setup {
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				-- defaults = {
				--   mappings = {
				--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
				--   },
				-- },
				-- pickers = {}
				extensions = {
					['ui-select'] = {
						require('telescope.themes').get_dropdown(),
					},
				},
			}

			-- Enable Telescope extensions if they are installed
			pcall(require('telescope').load_extension, 'fzf')
			pcall(require('telescope').load_extension, 'ui-select')

			-- See `:help telescope.builtin`
			local builtin = require 'telescope.builtin'
			vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
			vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
			vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
			vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
			vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
			vim.keymap.set('n', '<leader>s.', builtin.oldfiles,
				{ desc = '[S]earch Recent Files ("." for repeat)' })
			vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

			-- Slightly advanced example of overriding default behavior and theme
			vim.keymap.set('n', '<leader>/', function()
				-- You can pass additional configuration to Telescope to change the theme, layout, etc.
				builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
					winblend = 10,
					previewer = false,
				})
			end, { desc = '[/] Fuzzily search in current buffer' })

			vim.keymap.set('n', '<leader>sn', function()
				builtin.find_files { cwd = vim.fn.stdpath 'config' }
			end, { desc = '[S]earch [N]eovim files' })
		end,
	},
	-- NOTE: Treesitter for parsing text for better readability and more
	{
		"nvim-treesitter/nvim-treesitter",
		version = false, -- last release is way too old and doesn't work on Windows
		run = ":TSUpdate",
		cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
		keys = {
			{ "<c-space>", desc = "Increment Selection" },
			{ "<bs>",      desc = "Decrement Selection", mode = "x" },
		},
		opts_extend = { "ensure_installed" },
		opts = {
			highlight = {
				enable = true, -- false will disable the whole extension
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			ensure_installed = {
				"bash",
				"c",
				"css",
				"diff",
				"html",
				"javascript",
				"jsdoc",
				"json",
				"jsonc",
				"lua",
				"luadoc",
				"luap",
				"markdown",
				"markdown_inline",
				"printf",
				"python",
				"query",
				"regex",
				"toml",
				"tsx",
				"typescript",
				"vim",
				"vimdoc",
				"vue",
				"xml",
				"yaml",
			},
		},
	},
	-- NOTE: Improved readability for vue code
	{
		'posva/vim-vue',
	},
	-- NOTE: Nice comment styling
	{ 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
	-- NOTE: from LazyVim distro
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" },                       -- digits
					e = {                                      -- Word with case
						{ "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
						"^().*()$",
					},
					i = LazyVim.mini.ai_indent, -- indent
					g = LazyVim.mini.ai_buffer, -- buffer
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			LazyVim.on_load("which-key.nvim", function()
				vim.schedule(function()
					LazyVim.mini.ai_whichkey(opts)
				end)
			end)
		end,
	},
	-- NOTE: Prefered nvim file explorer
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
		config = function()
			vim.keymap.set('n', '<C-n>', '<CMD>Neotree toggle<CR>')
		end
	},
	-- NOTE: Nice looking bar on the bottom
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		opts = {
			theme = 'auto'
		},
	},
	-- NOTE: For recovering from undo mistakes and managing undo branches
	{
		"mbbill/undotree",
		keys = {
			{ "<leader>tu", "<cmd>UndotreeToggle<cr>", desc = "UndoTree" }
		}
	},
	-- NOTE: Powerful git terminal client
	{
		"kdheepak/lazygit.nvim",
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		-- optional for floating window border decoration
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		-- setting the keybinding for LazyGit with 'keys' is recommended in
		-- order to load the plugin when the command is run for the first time
		keys = {
			{ "<leader>tg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
		}
	},
	-- NOTE: For managing lsps, linters, formatters, and more (older alternative to Mason, Null-ls, nvim-cmp, etc) - this approach had the least vue sfc issues
	{
		"neoclide/coc.nvim",
		branch = "release",
		config = function()
			vim.cmd([[autocmd ColorScheme * highlight default link CocHighlightGroup NONE]])

			-- https://raw.githubusercontent.com/neoclide/coc.nvim/master/doc/coc-example-config.lua

			-- Some servers have issues with backup files, see #649
			vim.opt.backup = false
			vim.opt.writebackup = false


			-- Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
			-- delays and poor user experience
			vim.opt.updatetime = 300

			-- Always show the signcolumn, otherwise it would shift the text each time
			-- diagnostics appeared/became resolved
			vim.opt.signcolumn = "yes"

			local keyset = vim.keymap.set
			-- Autocomplete
			function _G.check_back_space()
				local col = vim.fn.col('.') - 1
				return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
			end

			-- Use Tab for trigger completion with characters ahead and navigate
			-- NOTE: There's always a completion item selected by default, you may want to enable
			-- no select by setting `"suggest.noselect": true` in your configuration file
			-- NOTE: Use command ':verbose imap <tab>' to make sure Tab is not mapped by
			-- other plugins before putting this into your config
			local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
			keyset("i", "<TAB>",
				'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()',
				opts)
			keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

			-- Make <CR> to accept selected completion item or notify coc.nvim to format
			-- <C-g>u breaks current undo, please make your own choice
			keyset("i", "<CR>",
				[[coc#pum#visible() ? coc#pum#confirm() : "\<CR>"]],
				opts)

			-- Use <c-j> to trigger snippets
			keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")

			-- Use <c-space> to trigger completion
			keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

			-- Use `[g` and `]g` to navigate diagnostics
			-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
			keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
			keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

			-- GoTo code navigation
			keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
			keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
			keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
			keyset("n", "gr", "<Plug>(coc-references)", { silent = true })


			-- Use K to show documentation in preview window
			function _G.show_docs()
				local cw = vim.fn.expand('<cword>')
				if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
					vim.api.nvim_command('h ' .. cw)
				elseif vim.api.nvim_eval('coc#rpc#ready()') then
					vim.fn.CocActionAsync('doHover')
				else
					vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
				end
			end

			keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })


			-- Symbol renaming
			keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })


			-- Formatting selected code
			keyset("x", "<leader>cf", "<Plug>(coc-format-selected)", { silent = true })
			keyset("n", "<leader>cf", "<Plug>(coc-format-selected)", { silent = true })

			vim.api.nvim_create_augroup("CocGroup", {})

			-- Setup formatexpr specified filetype(s)
			vim.api.nvim_create_autocmd("FileType", {
				group = "CocGroup",
				pattern = "typescript,json",
				command = "setl formatexpr=CocAction('formatSelected')",
				desc = "Setup formatexpr specified filetype(s)."
			})

			-- Update signature help on jump placeholder
			vim.api.nvim_create_autocmd("User", {
				group = "CocGroup",
				pattern = "CocJumpPlaceholder",
				command = "call CocActionAsync('showSignatureHelp')",
				desc = "Update signature help on jump placeholder"
			})

			-- Apply codeAction to the selected region
			-- Example: `<leader>aap` for current paragraph
			local opts = { silent = true, nowait = true }
			keyset("x", "<leader>ca", "<Plug>(coc-codeaction-selected)", opts)
			keyset("n", "<leader>ca", "<Plug>(coc-codeaction-selected)", opts)

			-- Remap keys for apply code actions at the cursor position.
			keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", opts)
			-- Remap keys for apply source code actions for current file.
			keyset("n", "<leader>as", "<Plug>(coc-codeaction-source)", opts)
			-- Apply the most preferred quickfix action on the current line.
			keyset("n", "<leader>cf", "<Plug>(coc-fix-current)", opts)

			-- Remap keys for apply refactor code actions.
			keyset("n", "<leader>re", "<Plug>(coc-codeaction-refactor)", { silent = true })
			keyset("x", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })
			keyset("n", "<leader>r", "<Plug>(coc-codeaction-refactor-selected)", { silent = true })

			-- Run the Code Lens actions on the current line
			keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)


			-- Map function and class text objects
			-- NOTE: Requires 'textDocument.documentSymbol' support from the language server
			keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
			keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
			keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
			keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
			keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
			keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
			keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
			keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)


			-- Remap <C-f> and <C-b> to scroll float windows/popups
			---@diagnostic disable-next-line: redefined-local
			local opts = { silent = true, nowait = true, expr = true }
			keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
			keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
			keyset("i", "<C-f>",
				'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
			keyset("i", "<C-b>",
				'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
			keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
			keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)


			-- Use CTRL-S for selections ranges
			-- Requires 'textDocument/selectionRange' support of language server
			keyset("n", "<C-s>", "<Plug>(coc-range-select)", { silent = true })
			keyset("x", "<C-s>", "<Plug>(coc-range-select)", { silent = true })


			-- Add `:Format` command to format current buffer
			vim.api.nvim_create_user_command('Format', function()
				local success, _ = pcall(vim.cmd, "CocCommand prettier.forceFormatDocument")
				if not success then
					-- Fallback to CocAction('format') if Prettier fails
					vim.cmd("call CocAction('format')")
				end
			end, {})
			vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
			keyset("n", "<leader>df", "<CMD>call CocAction('format')<CR>", { silent = true, noremap = true })

			-- " Add `:Fold` command to fold current buffer
			vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", { nargs = '?' })

			-- Add `:OR` command for organize imports of the current buffer
			vim.api.nvim_create_user_command("OR",
				"call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

			-- Add (Neo)Vim's native statusline support
			-- NOTE: Please see `:h coc-status` for integrations with external plugins that
			-- provide custom statusline: lightline.vim, vim-airline
			vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")

			-- Mappings for CoCList
			-- code actions and coc stuff
			---@diagnostic disable-next-line: redefined-local
			local opts = { silent = true, nowait = true }
			-- Show all diagnostics
			keyset("n", "<leader>cd", ":<C-u>CocList diagnostics<cr>", opts)
			-- Manage extensions
			keyset("n", "<leader>tce", ":<C-u>CocList extensions<cr>", opts)
			-- Show commands
			keyset("n", "<leader>tcc", ":<C-u>CocList commands<cr>", opts)
			-- Find symbol of current document
			keyset("n", "<leader>ao", ":<C-u>CocList outline<cr>", opts)
			-- Search workspace symbols
			keyset("n", "<space>tcs", ":<C-u>CocList -I symbols<cr>", opts)
			-- Do default action for next item
			keyset("n", "<leader>j", ":<C-u>CocNext<cr>", opts)
			-- Do default action for previous item
			keyset("n", "<leader>k", ":<C-u>CocPrev<cr>", opts)
			-- Resume latest coc list
			keyset("n", "<leader>tcp", ":<C-u>CocListResume<cr>", opts)

			-- Define the :Prettier command
			vim.api.nvim_create_user_command('Prettier', function()
				vim.cmd('CocCommand prettier.forceFormatDocument')
			end, {})
		end,
	},
	-- NOTE: Coc plugins START
	{
		'neoclide/coc-tsserver',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-stylelint',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'josa42/coc-lua',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-prettier',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-eslint',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-css',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-html',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-json',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'yaegassy/coc-volar',
		build = 'npm install --legacy-peer-deps'
	},
	{
		'neoclide/coc-pairs',
		build = 'npm install --legacy-peer-deps'
	},
	-- NOTE: Coc plugins END

})
