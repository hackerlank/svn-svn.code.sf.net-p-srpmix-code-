" /usr/share/vim/vim72/filetype.vim
:let html_number_lines=1
:let html_use_css=1
:let use_xhtml=1
:let g:kconfig_syntax_heavy=1

:syntax enable
:set filetype

":runtime! syntax/2html.vim
:source /home/yamato/var/srpmix/syntax/2html.vim
:write $SYNTAX_OUTPUT_FILE
:quit!
:quit!

