source /usr/share/cachyos-fish-config/cachyos-config.fish

function fish_greeting
end

if status is-interactive
    alias vim nvim
    alias vi nvim
    alias yay paru
    alias ls='eza -al --color=always --group-directories-first --icons=always'

    # same look as the herdr workspace picker
    set -x FZF_DEFAULT_OPTS "
  --layout reverse --border none --info inline-right
  --prompt '❯ ' --pointer '▌' --marker '▌' --gutter ' '
  --color 'bg:#000000,bg+:#313244,fg:#bac2de,fg+:#cdd6f4,hl:#89b4fa,hl+:#89b4fa,prompt:#89b4fa,pointer:#89b4fa,marker:#a6e3a1,info:#6c7086,ghost:#6c7086,header:#6c7086,footer:#6c7086,border:#45475a,separator:#45475a,scrollbar:#45475a'
  --preview-window 'right,50%,border-left'"

    set -x FZF_CTRL_T_COMMAND 'fd -H . ~ -E node_modules -E target -E .git -E .venv -E dist'
    set -x FZF_CTRL_T_OPTS "
  --walker-skip .git,node_modules,target
  --ghost 'find a file…'
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'
  --footer '↑↓ move   ⏎ insert   ⇥ mark   ^/ preview   esc quit'"

    set -x FZF_CTRL_R_OPTS "
  --ghost 'search history…'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --footer '↑↓ move   ⏎ insert   ^y copy   ^r sort   esc quit'"

    set -x FZF_ALT_C_COMMAND 'fd -H -t d . ~ -E node_modules -E target -E .git -E .venv -E dist'
    set -x FZF_ALT_C_OPTS "
  --ghost 'jump to a directory…'
  --preview 'eza -1 -a --icons=always --group-directories-first --color=always {}'
  --footer '↑↓ move   ⏎ cd   esc quit'"

    command -v zoxide &>/dev/null && zoxide init fish --cmd cd | source
    command -v starship &>/dev/null && starship init fish | source
    fzf --fish | source
    mise activate fish | source

    # plain `herdr` opens a workspace for the current dir, like `tmux new`
    function herdr --wraps herdr
        if test (count $argv) -gt 0; or set -q HERDR_ENV
            command herdr $argv
            return
        end
        __herdr_up
        ~/.config/herdr/workspace-picker.sh $PWD >/dev/null
        command herdr
    end

    function __herdr_up
        command herdr workspace list &>/dev/null; and return
        command herdr server &>/dev/null &
        disown
        for i in (seq 20)
            command herdr workspace list &>/dev/null; and break
            sleep 0.1
        end
    end

    # pick a workspace dir and attach
    function herdr-connect
        __herdr_up
        set -l dir (~/.config/herdr/workspace-picker.sh)
        and test -n "$dir"; and not set -q HERDR_ENV
        and command herdr
        commandline -f repaint
    end
    bind \co herdr-connect

    # rename herdr tabs as soon as a command starts (herdr-automatic-rename)
    for _f in $HOME/.config/herdr/plugins/github-installations/herdr-automatic-rename-*/*/checkout/shell/hook.fish
        test -r "$_f"; and source "$_f"; and break
    end
end

set -gx EDITOR nvim
export PATH="$HOME/.local/bin:$PATH"
