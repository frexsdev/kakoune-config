# config

set-option global tabstop 4
set-option global indentwidth 4
set-option global scrolloff 1,3
# set-option global ui_options "terminal_status_on_top=true"

set global grepcmd 'rg'

# hook global ModuleLoaded x11 %{
# 	set-option global termcmd 'wezterm cli split-pane --horizontal -- '
# }

add-highlighter global/ regex \h+$ 0:Error
add-highlighter global/ wrap -word -indent

# mappings

map global normal <space> , -docstring 'leader'
map global normal <backspace> <space> -docstring 'remove all sels except main'
map global normal <a-backspace> <a-space> -docstring 'remove main sel'

map global normal <tab> ': try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'
map global insert <tab> '<a-;>: try lsp-snippets-select-next-placeholders catch %{ execute-keys -with-hooks <lt>tab> }<ret>' -docstring 'Select next snippet placeholder'

# user mode

map -docstring "(un)comment current line/block" global user ";" ': comment<ret>'

## peneira mode
declare-user-mode peneira-mode
map -docstring "find file" global peneira-mode f ': peneira-files<ret>'
map -docstring "find line" global peneira-mode l ': peneira-lines<ret>'
map -docstring "find symbol" global peneira-mode s ': peneira-symbols<ret>'
map -docstring "peneira mode" global user p ':enter-user-mode peneira-mode<ret>'

## surround mode
declare-user-mode surround-mode
map global surround-mode s ':surround<ret>' -docstring 'surround'
map global surround-mode c ':change-surround<ret>' -docstring 'change'
map global surround-mode d ':delete-surround<ret>' -docstring 'delete'
map global surround-mode t ':select-surrounding-tag<ret>' -docstring 'select tag'
map -docstring "surround mode" global user s ':enter-user-mode surround-mode<ret>'

## lsp
map -docstring "hover" global user k ': lsp-hover<ret>'
map -docstring "code actions" global user a ': lsp-code-actions<ret>'
map -docstring 'format file' global user f ': lsp-formatting<ret>'
map -docstring 'rename' global user r ': lsp-rename-prompt<ret>'

# commands

define-command -docstring "save and quit" x "write-all; quit"

define-command -docstring "(un)comment current line/block" comment %{
	try %{
		execute-keys _
		comment-block
	} catch comment-line
}

# hooks

hook global InsertCompletionShow .* %{
	try %{
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
        hook -once -always window InsertCompletionHide .* %{
            unmap window insert <tab> <c-n>
            unmap window insert <s-tab> <c-p>
        }
    }
}

hook global WinCreate .* %{
	add-highlighter window/number-lines number-lines -relative -hlcursor
}

hook global BufWritePost .* lsp-formatting

# plugins

eval %sh{kak-lsp --kakoune -s $kak_session}
lsp-enable

source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

plug vbauerster/wezterm.kak %{
	wezterm-integration-enable
}

plug "alexherbo2/auto-pairs.kak" %{
    enable-auto-pairs
}

plug 'delapouite/kakoune-buffers' %{
	map global user b ': enter-buffers-mode<ret>' -docstring 'buffers'
}

# plug "andreyorst/powerline.kak" defer powerline %{
#     powerline-format global 'git bufname filetype mode_info line_column position'
# }  config %{
#     powerline-start
# }

# plug "andreyorst/kaktree" config %{
# 	hook global WinSetOption filetype=kaktree %{
# 		remove-highlighter buffer/numbers
# 		remove-highlighter buffer/matching
# 		remove-highlighter buffer/wrap
# 		remove-highlighter buffer/show-whitespaces
# 	}
# 	kaktree-enable
# }

# plug "occivink/kakoune-snippets"

plug "andreyorst/tagbar.kak" defer "tagbar" %{
    set-option global tagbar_sort false
    set-option global tagbar_size 40
    set-option global tagbar_display_anon false
} config %{
    hook global WinSetOption filetype=tagbar %{
		remove-highlighter window/wrap
    }
}

plug "dracula/kakoune"

plug 'delapouite/kakoune-cd' %{
	map global user c ': enter-user-mode cd<ret>' -docstring 'cd'

	alias global cdb change-directory-current-buffer
	alias global cdr change-directory-project-root
	alias global ecd edit-current-buffer-directory
	alias global pwd print-working-directory
}

plug "greenfork/active-window.kak"

plug "caksoylar/kakoune-smooth-scroll"

plug "maximbaz/restclient.kak"

plug "NNBnh/coderun.kak"

plug "gustavo-hms/luar" %{
	plug "gustavo-hms/peneira" %{
		require-module peneira
		set-option global peneira_files_command "rg --files"
	}

	plug "enricozb/tabs.kak" %{
		set-option global modelinefmt_tabs '%val{cursor_line}:%val{cursor_char_column} {{context_info}} {{mode_info}}'
		set-option global tabs_overlow "scroll"
	}
}

plug "h-youhei/kakoune-surround"

