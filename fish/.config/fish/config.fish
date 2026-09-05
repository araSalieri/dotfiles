source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
end

function tmux
    if test (count $argv) -eq 0; and not set -q TMUX
        set -l name (basename $PWD | string replace -a -r '[:.\s]' '-')
        command tmux new-session -A -s $name
    else
        command tmux $argv
    end
end

mise activate fish | source

if status is-interactive
    alias vim nvim
    alias vi nvim

    set -x FZF_CTRL_T_COMMAND 'fd -H . ~ -E node_modules -E target -E .git -E .venv -E dist'
    set -x FZF_CTRL_T_OPTS "
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

    set -x FZF_CTRL_R_OPTS "
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

    set -x FZF_ALT_C_COMMAND 'fd -H -t d . ~ -E node_modules -E target -E .git -E .venv -E dist'

    set -x FZF_ALT_C_OPTS "
  --preview 'tree -C {}'"

    fzf --fish | source
end
