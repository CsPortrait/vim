" airline {{{ "
    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tabline#formatter = 'jsformatter'
    let g:airline#extensions#tabline#tab_nr_type = 1
" }}} airline "

" simpylfold {{{ "
    let g:SimpylFold_docstring_preview = 1
" }}} simpylfold "

" fzf {{{ "
    nnoremap <silent> <M-f> :Files<CR>
    nnoremap <silent> <C-f> :GFiles<CR>
    nnoremap <silent> <C-s> :GFiles?<CR>
    nnoremap <silent> <C-b> :Buffers<CR>
    nnoremap <silent> <C-g> :RG<CR>
    " vim registers <C-/> as <C-_>
    " use <C-/> to trigger 'BLines' Command
    nnoremap <silent> <C-_> :BLines<CR>

    " [Buffers] Jump to the existing window if possible
    let g:fzf_buffers_jump = 1

    " Note: node_modules was ignored
    command! -bang -nargs=* Rg
        \ call fzf#vim#grep(
        \   'rg --column --line-number --no-heading --color=always --smart-case --glob "!node_modules" '.shellescape(<q-args>), 1,
        \   fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}), <bang>0)

    function! RipgrepFzf(query, fullscreen)
        let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
        let initial_command = printf(command_fmt, shellescape(a:query))
        let reload_command = printf(command_fmt, '{q}')
        let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
        " fzf#vim#with_preview: https://github.com/junegunn/fzf.vim/issues/975
        call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec, 'right:50%', 'ctrl-/'), a:fullscreen)
    endfunction
    command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

    let g:fzf_layout = { 'window': 'call CreateCenteredFloatingWindow()' }

    let g:fzf_history_dir = '~/.local/share/fzf-history'
" }}} fzf "

" nerdcommenter {{{ "
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1

    " Enable trimming of trailing whitespace when uncommenting
    let g:NERDTrimTrailingWhitespace = 1

    " Specifies the default alignment to use when inserting comments.
    let g:NERDDefaultAlign = 'left'
" }}} nerdcommenter "

" startify {{{ "
    nnoremap <silent> <F2> :Startify<CR>

    " When opening a file or bookmark, don't change to its directory
    let g:startify_change_to_dir = 0

    " How do I get both Defx and Startify working at startup?~
    autocmd VimEnter *
            \   if !argc()
            \ |   Startify
            \ |   Defx
            \ |   wincmd w
            \ | endif

    " change order
    let g:startify_lists = [
          \ { 'type': 'dir',       'header': ['   MRU '. getcwd()] },
          \ { 'type': 'files',     'header': ['   MRU']            },
          \ { 'type': 'sessions',  'header': ['   Sessions']       },
          \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      },
          \ { 'type': 'commands',  'header': ['   Commands']       },
          \ ]
" }}} startify "

" vista {{{ "
    " default executive
    let g:vista_default_executive="coc"
    let g:vista_executive_for = {
        \ 'sh': 'ctags',
        \ 'vim': 'ctags',
        \ 'markdown': 'ctags',
        \ }
    let g:airline#extensions#vista#enabled = 0

    " fzf - preview
    let g:vista_fzf_preview = ['right:50%']

    let g:vista#renderer#icons = {
    \   "keyword": "\uf1de",
    \   "variable": "\ue79b",
    \   "value": "\uf89f",
    \   "operator": "\u03a8",
    \   "function": "\u0192",
    \   "reference": "\ufa46",
    \   "constant": "\uf8fe",
    \   "method": "\uf09a",
    \   "struct": "\ufb44",
    \   "class": "\uf0e8",
    \   "interface": "\uf417",
    \   "text": "\ue612",
    \   "enum": "\uf435",
    \   "enumMember": "\uf02b",
    \   "module": "\uf40d",
    \   "color": "\ue22b",
    \   "property": "\ue624",
    \   "field": "\uf9be",
    \   "unit": "\uf475",
    \   "event": "\ufacd",
    \   "file": "\uf723",
    \   "folder": "\uf114",
    \   "snippet": "\ue60b",
    \   "typeParameter": "\uf728",
    \   "default": "\uf29c"
    \  }
" }}} vista "

" vim-javascript {{{ "
    let g:javascript_plugin_jsdoc = 1
" }}} vim-javascript "

" ale {{{ "
    let g:ale_sign_error = '✗'
    let g:ale_sign_warning = '⚡'
    let g:airline#extensions#ale#enabled = 1
" }}} ale "

" coc.nvim {{{ "
    let g:coc_global_extensions = [
        \ 'coc-yank',
        \ 'coc-word',
        \ 'coc-spell-checker',
        \ 'coc-snippets',
        \ 'coc-prettier',
        \ 'coc-tsserver',
        \ 'coc-json',
        \ 'coc-clangd',
        \ 'coc-go',
        \ ]

    " make snippet completion work just like VSCode
    inoremap <silent><expr> <TAB>
        \ pumvisible() ? coc#_select_confirm() :
        \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()

    function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    let g:coc_snippet_next = '<Tab>'
    let g:coc_snippet_prev = '<S-Tab>'

    " Use K to show documentation in preview window
    nnoremap <silent> K :call <SID>show_documentation()<CR>

    function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
        elseif (coc#rpc#ready())
            call CocActionAsync('doHover')
        else
            execute '!' . &keywordprg . " " . expand('<cword>')
        endif
    endfunction

    nmap <leader>rn <Plug>(coc-rename)

    nmap <silent> gd <Plug>(coc-definition)
    nmap <silent> gy <Plug>(coc-type-definition)
    nmap <silent> <leader>gi <Plug>(coc-implementation)
    nmap <silent> gr <Plug>(coc-references)

    nnoremap <silent> <Leader>f :call CocAction('format')<CR>

    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Use `[g` and `]g` to navigate diagnostics
    nmap <silent> [g <Plug>(coc-diagnostic-prev)
    nmap <silent> ]g <Plug>(coc-diagnostic-next)

    augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Applying codeAction to the selected region.
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)
    " Remap keys for applying codeAction to the current buffer.
    nmap <leader>ac  <Plug>(coc-codeaction)

    " Apply AutoFix to problem on the current line.
    nmap <leader>af  <Plug>(coc-fix-current)

    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    let g:coc_disable_transparent_cursor=1
" }}} coc.nvim "

" vim-test {{{ "
    let g:test#strategy = "neovim"
    nnoremap <silent> <F5> :TestFile<CR>
    nnoremap <silent> <F6> :TestNearest<CR>

    let test#go#gotest#options = {
    \   'all':   '-v',
    \ }
" }}} vim-test "

" vim-quickui {{{ "
    " clear all the menus
    call quickui#menu#reset()

    call quickui#menu#install('&Tool', [
        \ [ "Startify\tF2", 'Startify' ],
        \ [ "DefxFi&nd\tF4", "DefxFind" ],
        \ [ "--", '' ],
        \ [ "&AutoSelectTextAfterPasteToggle", 'exec "AutoSelectTextAfterPasteToggle"' ],
        \ [ "CloseSpecific&Buffer", 'exec "CloseSpecificBuffer"' ],
        \ [ "Cs&Glow-Float", 'exec "CsGlow 1"' ],
        \ [ "CsGlow-Normal", 'exec "CsGlow 2"' ],
        \ [ "--", '' ],
        \ [ "TestFile\tF5", 'TestFile'],
        \ [ "&TestNearest\tF6", 'TestNearest' ],
        \ [ "--", '' ],
        \ [ "&PmR", 'CocList pmr' ],
        \ [ "PmR-Reset", 'CocCommand qtk.pmr.reset' ],
        \ [ "&CpR", 'CocCommand qtk.cpr.exec' ],
        \ [ "CpR-Reset", 'CocCommand qtk.cpr.reset' ],
        \ [ "&Switching", "CocCommand qtk.switching" ],
        \ [ "--", '' ],
        \ [ "&VistaToogle", 'Vista!!' ],
        \ [ "VistaFinder", 'Vista finder' ],
        \ [ "--", '' ],
        \ [ "&MarkdownPreview", 'MarkdownPreview' ],
        \ [ "MarkdownPreviewStop", 'MarkdownPreviewStop' ],
        \ [ "--", '' ],
        \ [ "&OR", "call CocAction('runCommand', 'editor.action.organizeImport')" ],
        \ [ "&ExchangeClear", "execute 'normal \<Plug>(ExchangeClear)'" ],
        \ [ "Coc&Restart", "CocRestart" ],
        \ [ "CocClose&Floats", "call coc#util#close_floats()" ],
        \ ])

    call quickui#menu#install('&Git', [
        \ [ '&diffsplit', 'Gdiffsplit'],
        \ [ '&vdiffsplit', 'Gvdiffsplit'],
        \ [ '&blame', 'Gblame'],
        \ [ 'lo&g', '0Glog'],
        \ [ "--", '' ],
        \ [ '&status', 'aboveleft Gstatus'],
        \ [ '&commit', 'CsConfirm Gcommit'],
        \ [ "--", '' ],
        \ [ '&read(checkout)', 'Gread'],
        \ [ '&write(add)', 'Gwrite'],
        \ ])

    " register HELP menu with weight 1000
    call quickui#menu#install('Help', [
        \ ["&Cheatsheet", 'help index', ''],
        \ ['T&ips', 'help tips', ''],
        \ ['--',''],
        \ ["&Tutorial", 'help tutor', ''],
        \ ['&Quick Reference', 'help quickref', ''],
        \ ], 10000)

    " enable to display tips in the cmdline
    let g:quickui_show_tip = 1

    " hit space twice to open menu
    noremap <silent> <Leader><Leader> :call quickui#menu#open()<cr>

    let g:quickui_border_style = 2
    let g:quickui_color_scheme = 'gruvbox'
" }}} vim-quickui "

" vim-gitgutter {{{ "
    let g:gitgutter_preview_win_floating = 1
    let g:airline#extensions#hunks#enabled = 0
" }}} vim-gitgutter "

" markdown-preview.nvim {{{ "
    let g:mkdp_auto_close = 0
" }}} markdown-preview.nvim "

" vim-floaterm {{{ "
    let g:floaterm_type = 'floating'
    let g:floaterm_position = 'bottomright'
    let g:floaterm_width = 0.99
    let g:floaterm_height = 0.6

    " This plugin leaves an empty buffer on startify window
    autocmd User Startified setlocal buflisted

    nnoremap <silent> <M-j> :FloatermToggle<CR>
    tnoremap <silent> <M-j> <C-\><C-N>:FloatermToggle<CR>
    inoremap <silent> <M-j> <Esc>:FloatermToggle<CR>
" }}} vim-floaterm "

" cycle.vim {{{ "
    let g:cycle_no_mappings = 1
    noremap <silent> <Plug>CycleFallbackNext <C-A>
    noremap <silent> <Plug>CycleFallbackPrev <C-X>
    nmap <silent> <C-a> <Plug>CycleNext
    nmap <silent> <C-x> <Plug>CyclePrev


    let g:cycle_default_groups = [
        \   [[',', '，']],
        \   [['.', '。']],
        \   [['?', '？']],
        \   [[';', '；']],
        \   [[':', '：']],
        \   [['(:)','（:）'], 'sub_pairs'],
        \   [['是', '否']],
        \   [['+', '-']],
        \   [['++', '--']],
        \   [['>', '<']],
        \   [['||', '&&']],
        \   [['===', '!==']],
        \   [['==', '!=']],
        \   [['true', 'false']],
        \   [['yes', 'no']],
        \   [['on', 'off']],
        \   [['and', 'or']],
        \   [["in", "out"]],
        \   [["increase", "decrease"]],
        \   [["up", "down"]],
        \   [["min", "max"]],
        \   [["get", "set"]],
        \   [["add", "remove"]],
        \   [["to", "from"]],
        \   [["read", "write"]],
        \   [["only", "except"]],
        \   [['without', 'with']],
        \   [["exclude", "include"]],
        \   [["asc", "desc"]],
        \   [["begin", "end"]],
        \   [["first", "last"]],
        \   [["slow", "fast"]],
        \   [["small", "large"]],
        \   [["push", "pull"]],
        \   [["before", "after"]],
        \   [["new", "delete"]],
        \   [["while", "until"]],
        \   [["left", "right"]],
        \   [["top", "bottom"]],
        \   [["one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten"]],
        \   [
        \       ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
        \       'hard_case', {'name': 'Days'}
        \   ],
        \   [
        \       ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
        \       'hard_case', {'name': 'Months'}
        \   ],
        \ ]
" }}} cycle.vim "

" editorconfig-vim {{{ "
    let g:EditorConfig_exclude_patterns = ['fugitive://.*']
" }}} editorconfig-vim "

" fugitive.vim {{{ "
    let g:airline#extensions#branch#enabled = 0
    let g:fugitive_pty = 0
" }}} fugitive.vim "

" vim-zoom {{{ "
    " like tmux,  prefix-z
    nmap <Leader>z <Plug>(zoom-toggle)
" }}} vim-zoom "

" vim-exchange {{{ "
    xmap <C-x>  <Plug>(Exchange)
" }}} vim-exchange "

" indentLine {{{ "
    let g:indentLine_char = '│'
    let g:indentLine_fileTypeExclude = ['startify', 'vista', 'json', 'jsonc', 'man', 'help', 'markdown']
" }}} indentLine "

" vim-browser-search {{{ "
    nmap <silent> <Leader>s <Plug>SearchNormal
    vmap <silent> <Leader>s <Plug>SearchVisual
" }}} vim-browser-search "

" linediff.vim {{{ "
    nnoremap <Leader>l :Linediff<CR>
    xnoremap <Leader>l :Linediff<CR>
" }}} linediff.vim "

" vim-carbon-now-sh {{{ "
    let g:carbon_now_sh_options = {
        \ 'fm': 'Source Code Pro'
        \ }
" }}} vim-carbon-now-sh "

" defx {{{ "
    " reference:
    "   1. :help defx
    "   2. https://github.com/hardcoreplayers/ThinkVim/blob/62f75d5ae1722ba5839de8ea50bb7ad2871e7593/modules/module-defx.vim
    nnoremap <silent> <Leader>e :Defx<CR>
    command! -nargs=0 DefxFind :call <SID>defx_find()
    nnoremap <silent> <F4> :DefxFind<CR>

    let g:defx_icons_parent_icon = "\uf113"
    let g:defx_icons_column_length = 2

    call defx#custom#option('_',{
        \ 'columns'   : 'indent:git:icons:filename',
        \ 'split'     : 'vertical',
        \ 'direction' : 'topleft',
        \ 'winwidth'  : 25,
        \ 'show_ignored_files': 0,
        \ 'buffer_name': 'defx-' . tabpagenr(),
        \ 'auto_cd': 0,
        \ 'toggle': 1,
        \ 'resume': 1,
        \ 'ignored_files': ".*,node_modules",
        \ 'root_marker': '[in]: ',
        \ 'floating_preview': 1,
        \ 'vertical_preview': 1,
        \ 'preview_width': &columns > 80 ? 80 : float2nr(&columns * 0.618),
        \ 'preview_height': float2nr(&lines * 0.618),
        \ })

    call defx#custom#column('git', {
        \   'indicators': {
        \     'Modified'  : '•',
        \     'Staged'    : '✚',
        \     'Untracked' : 'ᵁ',
        \     'Renamed'   : '➜',
        \     'Unmerged'  : '',
        \     'Ignored'   : 'ⁱ',
        \     'Deleted'   : '✖',
        \     'Unknown'   : ''
        \   }
        \ })

    augroup ft_defx
        autocmd!
        autocmd FileType defx call <SID>defx_settings()
        autocmd WinLeave * if &filetype == 'defx' | wincmd = | endif
        autocmd BufHidden * if exists('t:defx_column_maximal') && t:defx_column_maximal | let t:defx_column_maximal = v:false | endif
    augroup end

    " reference NERDTree
    " How can I open Defx automatically when vim starts up on opening a directory?
    " Note: Executing vim ~/some-directory will open Defx and a new edit window. exe 'cd '.argv()[0] sets the pwd of the new edit window to ~/some-directory
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'Defx' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif

    func! s:defx_find() abort
        let nr = 0
        for i in range(1, winnr('$'))
            if getwinvar(i, '&filetype') == 'defx'
                let nr = i
            endif
        endfor

        if nr == winnr()
            return
        endif

        let path = expand('%:p')
        if nr == 0
            execute 'Defx'
        else
            execute nr . 'wincmd w'
        endif

        call defx#call_action('search', path)
    endf

    func! s:defx_jump_dirty(dir) abort
        " Jump to the next position with defx-git dirty symbols
        let l:icons = get(g:, 'defx_git_indicators', {})
        let l:icons_pattern = join(values(l:icons), '\|')

        if ! empty(l:icons_pattern)
            let l:direction = a:dir > 0 ? 'w' : 'bw'
            return search(printf('\(%s\)', l:icons_pattern), l:direction)
        endif
    endf

    func! s:defx_cd() abort
        let dirPath = ''
        if defx#is_directory()
            let dirPath = defx#get_candidate().action__path
        else
            let dirPath = fnamemodify(defx#get_candidate().action__path, ':p:h')
        endif

        execute 'cd ' . dirPath
        echo "Defx: CWD is now: " . dirPath
    endf

    func! s:defx_drop_operation(arg) abort
        if defx#is_directory()
            return
        endif

        return defx#do_action('drop', a:arg)
    endf

    func! s:defx_change_root() abort
        if !defx#is_directory()
            return
        endif

        let dirPath = defx#get_candidate().action__path
        return defx#do_action('cd', [dirPath])
    endf

    func! s:defx_jump_tree_root() abort
        let paths = b:defx.paths
        if len(paths) != 1
            echo 'unexpected paths ' . paths
            return
        endif

        return defx#do_action('search', paths[0])
    endf

    func! s:defx_remove() abort
        let trash_cmd = "trash-put"
        if !executable(trash_cmd)
            echo 'no such cmd: ' . trash_cmd . ', abort'
            return
        endif

        let candidate = defx#get_candidate()
        let choice = confirm(candidate.action__path . ", delete it?", "&Yes\n&No", 2)
        if choice == 1
            execute  'silent !' . trash_cmd . ' ' . candidate.action__path
            echo candidate.action__path . ' was successfully deleted'
            call defx#call_action('redraw')
        endif
    endf

    func! s:defx_get_cursor_info() abort
        let candidate = defx#get_candidate()
        let parent = fnamemodify(candidate.action__path, ':h')
        let dirList = filter(
            \ split(execute('!ls -p ' . parent . " | grep -E '/$' | sort -f"), "\n")[1:],
            \ 'v:val != ""'
            \ )
        let fileList = filter(
            \ split(execute('!ls -p ' . parent . " | grep -vE '/$' | sort -f"), "\n")[1:],
            \ 'v:val != ""'
            \ )
        let list = dirList + fileList

        return { 'candidate': candidate, 'list': list, 'parent': parent, 'dirList': dirList, 'fileList': fileList }
    endf

    func! s:defx_first_last_child(direction) abort
        let info = <SID>defx_get_cursor_info()
        let parent = info.parent
        let list = info.list
        let listLen = len(list)

        if a:direction == 1
            return defx#do_action('search', parent . '/' . list[listLen - 1])
        else
            return defx#do_action('search', parent . '/' . list[0])
        endif
    endf

    func! s:defx_preview() abort
        let candidate = defx#get_candidate()
        if candidate.is_directory
            return
        endif

        let extList = [
            \ 'jpg', 'jpeg', 'png', 'gif',
            \ 'webp', 'svg', 'svgz', 'pdf',
            \ ]

        let ext = fnamemodify(candidate.action__path, ":e")
        if index(extList, ext) != -1
            return defx#do_action('execute_system')
        else
            return defx#do_action('preview')
        endif
    endf

    " TODO: support ignored_files
    func! s:defx_next_sibling(direction) abort
        let info = <SID>defx_get_cursor_info()
        let parent = info.parent
        let candidate = info.candidate
        let list = info.list

        let idx = index(list, candidate.word)
        if idx == -1
            return
        endif

        let listLen = len(list)
        let idx = (idx + a:direction + listLen) % listLen
        if idx >= 0 && idx < listLen
            let path = parent . '/' . list[idx]
            return defx#do_action('search', path)
        endif
    endf

    func! s:defx_column_zoom() abort
        if !exists('t:defx_column_maximal')
            let t:defx_column_maximal = v:false
        endif

        if t:defx_column_maximal
            let t:defx_column_maximal = v:false
            return defx#do_action('resize', 25)
        else
            let t:defx_column_maximal = v:true
            return defx#do_action('resize', &columns / 2 + 25)
        endif
    endf

    func! s:defx_fzf_file_helper(parent, item) abort
        call defx#call_action('search', a:parent . '/' . a:item)
    endf

    func! s:defx_fzf_file() abort
        let candidate = defx#get_candidate()
        let parent = candidate.action__path
        if !candidate.is_directory || !candidate.is_opened_tree
            let parent = fnamemodify(candidate.action__path, ':h')
        endif

        call fzf#run({
            \ 'name': 'files',
            \ 'window': 'call CreateCenteredFloatingWindow()',
            \ 'sink': function('<SID>defx_fzf_file_helper', [parent]),
            \ 'dir': parent,
            \ })
    endf

    func! s:defx_settings() abort
        setlocal nonumber
        setlocal norelativenumber

        " defx-git jump
        nnoremap <silent><buffer>  [c :<C-u>call <SID>defx_jump_dirty(-1)<CR>
        nnoremap <silent><buffer>  ]c :<C-u>call <SID>defx_jump_dirty(1)<CR>

        nnoremap <silent><buffer><expr> o
            \ defx#is_directory() ?
            \ defx#do_action('open_or_close_tree') :
            \ defx#do_action('drop')
        nmap <silent><buffer> <CR> o
        nnoremap <silent><buffer><expr> x defx#do_action('close_tree')
        nnoremap <silent><buffer><expr> . defx#do_action('toggle_ignored_files')
        nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
        nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
        nnoremap <silent><buffer><expr> p defx#do_action(
            \ 'search',
            \ fnamemodify(defx#get_candidate().action__path, ':h')
            \ )
        nnoremap <silent><buffer><expr> <C-r> defx#do_action('redraw')
        nnoremap <silent><buffer><expr> u defx#do_action('cd', ['..'])
        nnoremap <silent><buffer><expr> q defx#do_action('quit')
        nnoremap <silent><buffer><expr> ! defx#do_action('execute_command')
        nnoremap <silent><buffer><expr> <Leader>t defx#do_action(
            \ 'toggle_columns',
            \ 'indent:mark:filename:type:size:time'
            \ )
        nnoremap <silent><buffer><expr> <C-g> defx#do_action('print')
        nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
        nnoremap <silent><buffer><expr> C defx#do_action('copy')
        nnoremap <silent><buffer><expr> m defx#do_action('move')
        nnoremap <silent><buffer><expr> <Leader>p defx#do_action('paste')
        nnoremap <silent><buffer><expr> r defx#do_action('rename')
        nnoremap <silent><buffer><expr> M defx#do_action('new_directory')
        nnoremap <silent><buffer><expr> N defx#do_action('new_file')
        nnoremap <silent><buffer><expr> <Leader>o defx#do_action('execute_system')

        nnoremap <silent><buffer><expr> A <SID>defx_column_zoom()
        nnoremap <silent><buffer><expr> s <SID>defx_drop_operation('vsplit')
        nnoremap <silent><buffer><expr> i <SID>defx_drop_operation('split')
        nnoremap <silent><buffer><expr> t <SID>defx_drop_operation('tabe')
        nnoremap <silent><buffer><expr> cd <SID>defx_cd()
        nnoremap <silent><buffer><expr> C <SID>defx_change_root()
        nnoremap <silent><buffer><expr> P <SID>defx_jump_tree_root()
        nnoremap <silent><buffer> dd :call <SID>defx_remove()<CR>
        nnoremap <silent><buffer><expr> <C-j> <SID>defx_next_sibling(1)
        nnoremap <silent><buffer><expr> <C-k> <SID>defx_next_sibling(-1)
        nnoremap <silent><buffer><expr> J <SID>defx_first_last_child(1)
        nnoremap <silent><buffer><expr> K <SID>defx_first_last_child(-1)
        nnoremap <silent><buffer><expr> <C-p> <SID>defx_preview()
        nnoremap <silent><buffer> <C-f> :call <SID>defx_fzf_file()<CR>
    endf
" }}} defx "
