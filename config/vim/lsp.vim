" Enable diagnostics highlighting + insert-mode auto-completion popup
let lspOpts = #{autoHighlightDiags: v:true, autoComplete: v:true}
autocmd User LspSetup call LspOptionsSet(lspOpts)
let lspServers = [
      \ #{
      \   name: 'clangd',
      \   filetype: ['c', 'cpp'],
      \   path: 'clangd',
      \   args: []
      \ },
      \
      \ #{
      \   name: 'rust-analyzer',
      \   filetype: ['rust', 'rs'],
      \   path: 'rust-analyzer',
      \   args: []
      \ },
      \
      \ #{
      \   name: 'ruff',
      \   filetype: ['python', 'py'],
      \   path: 'ruff',
      \   args: ['server']
      \ },
      \
      \ #{
      \   name: 'basedpyright',
      \   filetype: ['python', 'py'],
      \   path: 'basedpyright-langserver',
      \   args: ['--stdio']
      \ },
      \
      \
      \ #{
      \   name: 'luau-lsp',
      \   filetype: ['luau'],
      \   path: 'luau-lsp',
      \   args: ['lsp']
      \ },
      \ ]

autocmd User LspSetup call LspAddServer(lspServers)

" Key mappings
nnoremap gd :LspGotoDefinition<CR>
nnoremap gr :LspShowReferences<CR>
nnoremap K  :LspHover<CR>
nnoremap gl :LspDiag current<CR>
nnoremap <leader>nd :LspDiag next \| LspDiag current<CR>
nnoremap <leader>pd :LspDiag prev \| LspDiag current<CR>
inoremap <silent> <C-Space> <C-x><C-o>

" Show quick-fix / code action suggestions for the diagnostic on the
" current line (the "lightbulb" popup you get in VSCode)
nnoremap <leader>ca :LspCodeAction<CR>

" Automatically pop up the diagnostic message when the cursor is on
" (or passes over) a line with an error/warning, instead of requiring gl
augroup LspDiagAutoPopup
  autocmd!
  autocmd CursorMoved * silent! LspDiag! current
augroup END

" Set omnifunc for completion
autocmd FileType php setlocal omnifunc=lsp#complete

" Custom diagnostic sign characters
autocmd User LspSetup call LspOptionsSet(#{
    \   diagSignErrorText: '✘',
    \   diagSignWarningText: '▲',
    \   diagSignInfoText: '»',
    \   diagSignHintText: '⚑',
    \ })
