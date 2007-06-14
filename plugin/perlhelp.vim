" vim600: set foldmethod=marker:
" =============================================================================
" File:         perlhelp.vim (global plugin)
" Last Changed: 2007-06-14
" Maintainer:   Lorance Stinson <LoranceStinson+perlhelp@gmail.com>
" Version:      1.2
" License:      Vim License
" =============================================================================

" Changes {{{1

" 1.2 2007-06-14
"   Removed 'setlocal iskeyword+=:' and used <cWORD> and a substitution
"   as suggested by Erik Falor.

" 1.1 2007-06-13
"   Added 'setlocal iskeyword+=:' to account for :'s in module names.

" Initialization. {{{1
" Allow user to avoid loading this plugin and prevent loading twice.
if exists ('loaded_perlhelp')
    finish
endif

let loaded_perlhelp = 1

" Make sure perlhelp is available and executable
if exists('perlhelp_prog')
    let s:perlhelp = perlhelp_prog
else
    let s:perlhelp = 'perldoc'
endif
if !executable(s:perlhelp)
  echoe 'perldoc is not installed!'
  finish
endif
let s:perlhelp = s:perlhelp . ' -T'

" Easy access functions. {{{2
:command! -nargs=? PerlFAQ  call <SID>PerlHelpFAQ(<f-args>)
:command! -nargs=? PerlFunc call <SID>PerlHelpFunc(<f-args>)
:command! -nargs=? PerlHelp call <SID>PerlHelp(<f-args>)
:command! -nargs=? PerlMod  call <SID>PerlHelpMod(<f-args>)

" Key mappings. {{{2
if !hasmapto('<Plug>PerlHelpNormal')
    nmap <silent> <unique> <Leader>ph <Plug>PerlHelpNormal
endif
if !hasmapto('<Plug>PerlHelpVisual')
    vmap <silent> <unique> <Leader>ph <Plug>PerlHelpVisual
endif
if !hasmapto('<Plug>PerlHelpAsk')
    nmap <silent> <unique> <Leader>PH <Plug>PerlHelpAsk
endif
if !hasmapto('<Plug>PerlHelpFuncNormal')
    nmap <silent> <unique> <Leader>pf <Plug>PerlHelpFuncNormal
endif
if !hasmapto('<Plug>PerlHelpFuncVisual')
    vmap <silent> <unique> <Leader>pf <Plug>PerlHelpFuncVisual
endif
if !hasmapto('<Plug>PerlHelpFuncAsk')
    nmap <silent> <unique> <Leader>PF <Plug>PerlHelpFuncAsk
endif
if !hasmapto('<Plug>PerlHelpModNormal')
    nmap <silent> <unique> <Leader>pm <Plug>PerlHelpModNormal
endif
if !hasmapto('<Plug>PerlHelpModVisual')
    vmap <silent> <unique> <Leader>pm <Plug>PerlHelpModVisual
endif
if !hasmapto('<Plug>PerlHelpModAsk')
    nmap <silent> <unique> <Leader>PM <Plug>PerlHelpModAsk
endif
if !hasmapto('<Plug>PerlHelpFAQNormal')
    nmap <silent> <unique> <Leader>pq <Plug>PerlHelpFAQNormal
endif
if !hasmapto('<Plug>PerlHelpFAQVisual')
    vmap <silent> <unique> <Leader>pq <Plug>PerlHelpFAQVisual
endif
if !hasmapto('<Plug>PerlHelpFAQAsk')
    nmap <silent> <unique> <Leader>PQ <Plug>PerlHelpFAQAsk
endif

" Plug mappings for the key mappings. {{{2
nmap <silent> <unique> <script> <Plug>PerlHelpNormal      :call <SID>PerlHelp(expand("<cWORD>"))<CR>
vmap <silent> <unique> <script> <Plug>PerlHelpVisual     y:call <SID>PerlHelp('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpAsk         :call <SID>PerlHelp(<SID>PerlHelpAsk("topic"))<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpFuncNormal  :call <SID>PerlHelpFunc(expand("<cWORD>"))<CR>
vmap <silent> <unique> <script> <Plug>PerlHelpFuncVisual y:call <SID>PerlHelpFunc('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpFuncAsk     :call <SID>PerlHelpFunc(<SID>PerlHelpAsk("function"))<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpModNormal   :call <SID>PerlHelpMod(expand("<cWORD>"))<CR>
vmap <silent> <unique> <script> <Plug>PerlHelpModVisual  y:call <SID>PerlHelpMod('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpModAsk      :call <SID>PerlHelpMod(<SID>PerlHelpAsk("module"))<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpFAQNormal   :call <SID>PerlHelpFAQ(expand("<cWORD>"))<CR>
vmap <silent> <unique> <script> <Plug>PerlHelpFAQVisual  y:call <SID>PerlHelpFAQ('<c-r>"')<CR>
nmap <silent> <unique> <script> <Plug>PerlHelpFAQAsk      :call <SID>PerlHelpFAQ(<SID>PerlHelpAsk("module"))<CR>

" Functions. {{{1
" Ask for text to lookup. {{{2
function <SID>PerlHelpAsk(prompt)
    let l:string = input('Enter the ' . a:prompt . ' to lookup: ')
    return l:string
endfunction

" Display help on a perl FAQ entry. {{{2
function <SID>PerlHelpFAQ(...)
    if a:0 == 0
        let l:re = <SID>PerlHelpAsk('FAQ regular expression')
    else
        let l:re = substitute(a:1, ';', '', '')
    endif
    let l:text = system(s:perlhelp . " -t -q " . l:re)
    call <SID>PerlHelpWindow(l:text, 0)
endfunction

" Display help on a perl function. {{{2
function <SID>PerlHelpFunc(...)
    if a:0 == 0
        let l:function = <SID>PerlHelpAsk('function')
    else
        let l:function = substitute(a:1, ';', '', '')
    endif
    let l:text = system(s:perlhelp . " -t -f " . l:function)
    call <SID>PerlHelpWindow(l:text, 0)
endfunction

" Just call perldoc with the argument. {{{2
function <SID>PerlHelp(...)
    if a:0 == 0
        let l:topic = <SID>PerlHelpAsk('topic')
    else
        let l:topic = substitute(a:1, ';', '', '')
    endif
    let l:text = system(s:perlhelp . " -t " . l:topic)
    call <SID>PerlHelpWindow(l:text, 0)
endfunction

" Display a perl module. {{{2
function <SID>PerlHelpMod(...)
    if a:0 == 0
        let l:module = <SID>PerlHelpAsk('module')
    else
        let l:module = substitute(a:1, ';', '', '')
    endif
    let l:text = system(s:perlhelp . " -m " . l:module)
    call <SID>PerlHelpWindow(l:text, 1)
endfunction

" Display the actual text. {{{2
" Split the window or use the existing split to display the text.
" Taken from asciitable.vim by Jeffrey Harkavy.
function <SID>PerlHelpWindow(command, syntax)
    let s:vheight = 19
    let s:vwinnum=bufnr('__PerlHelp')
    if getbufvar(s:vwinnum, 'PerlHelp')=='PerlHelp'
        let s:vwinnum=bufwinnr(s:vwinnum)
    else
        let s:vwinnum=-1
    endif
    
    if s:vwinnum >= 0
        " if already exist
        if s:vwinnum != bufwinnr('%')
          exe "normal \<c-w>" . s:vwinnum . 'w'
        endif
        setlocal modifiable
        silent %d _
    else
        execute s:vheight.'split __PerlHelp'
    
        setlocal noswapfile
        setlocal buftype=nowrite
        setlocal bufhidden=delete
        setlocal nonumber
        setlocal nowrap
        setlocal norightleft
        setlocal foldcolumn=0
        setlocal nofoldenable
        setlocal modifiable
        let b:PerlHelp='PerlHelp'
    endif

    silent put! =a:command
    setlocal nomodifiable
    1 " Skip to the top of the text.
    " Highlight the file. Used when looking up a module.
    if a:syntax==1
        set ft=perl
    else
        set ft=text
    endif
endfunction
