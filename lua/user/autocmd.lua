vim.cmd([[
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

augroup _general_settings
    autocmd!
    autocmd TextYankPost * silent! lua vim.highlight.on_yank{higroup="IncSearch", timeout=500}
    autocmd FileType qf set nobuflisted
augroup end

if !has('macunix')
	augroup _non_mac_settings
		autocmd TextYankPost *
			\ if v:event.operator is 'y' && v:event.regname is '+' |
			\   OSCYankReg + |
			\ endif
	augroup end
endif
]])
