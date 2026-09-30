source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
end

if status is-interactive
    alias vim nvim
    alias vi nvim
    alias yay paru

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

    command -v zoxide &>/dev/null && zoxide init fish --cmd cd | source
    command -v starship &>/dev/null && starship init fish | source
    fzf --fish | source
    mise activate fish | source

    function sesh-connect
        sesh connect (sesh list | fzf)
        commandline -f repaint
    end
    bind \co sesh-connect
end

set -gx EDITOR nvim
