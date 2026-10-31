source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
end

if status is-interactive
    alias vim nvim
    alias vi nvim
    alias yay paru
    alias ls='eza -al --color=always --group-directories-first --icons=always'

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
        set -l session (sesh list | fzf)
        and sesh connect $session
        commandline -f repaint
    end
    bind \co sesh-connect

    # plain `herdr` opens a workspace for the current dir, like `tmux new`
    function herdr --wraps herdr
        if test (count $argv) -gt 0; or set -q HERDR_ENV
            command herdr $argv
            return
        end
        if not command herdr workspace list &>/dev/null
            command herdr server &>/dev/null &
            disown
            for i in (seq 20)
                command herdr workspace list &>/dev/null; and break
                sleep 0.1
            end
        end
        ~/.config/herdr/workspace-picker.sh $PWD
        command herdr
    end
end

set -gx EDITOR nvim
export PATH="$HOME/.local/bin:$PATH"
