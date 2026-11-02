#!/usr/bin/env bash
# Pick a dir (zoxide, or fd with ctrl+f) and focus its herdr workspace, creating it if needed.
# With a dir argument, skip the picker and use that dir. Prints the chosen dir.
dir=${1:-}
# styled after the herdr-bar command bar
[ -n "$dir" ] || dir=$(zoxide query -l | fzf --no-sort --layout reverse --border none \
  --prompt '❯ ' --ghost 'jump to a workspace…' --pointer '▌' --marker ' ' --gutter ' ' --info inline-right \
  --color 'bg:#000000,bg+:#313244,fg:#bac2de,fg+:#cdd6f4,hl:#89b4fa,hl+:#89b4fa,prompt:#89b4fa,pointer:#89b4fa,info:#6c7086,ghost:#6c7086,header:#6c7086,footer:#6c7086,border:#45475a,separator:#45475a,scrollbar:#45475a' \
  --header '^x zoxide   ^f find' --header-first \
  --footer '↑↓ move   ⏎ open   ^x zoxide   ^f find   ^o preview   esc quit' \
  --preview 'eza -1 -a --icons=always --group-directories-first --color=always {}' \
  --preview-window 'right,35%,border-left' \
  --bind 'tab:down,btab:up,ctrl-o:toggle-preview' \
  --bind 'ctrl-x:change-ghost(jump to a workspace…)+reload(zoxide query -l)' \
  --bind 'ctrl-f:change-ghost(find a directory…)+reload(fd -H -d 2 -t d -E .Trash . ~)') || exit 0
dir=${dir%/}
label=$(basename "$dir")

# herdr keeps no workspace dir, so match a workspace with a pane in this dir (labels get renamed)
id=$(herdr pane list | jq -r --arg d "$dir" 'first(.result.panes[] | select(.cwd == $d) | .workspace_id) // empty')
if [ -n "$id" ]; then
  herdr workspace focus "$id" >/dev/null
else
  herdr workspace create --cwd "$dir" --label "$label" --focus >/dev/null
fi
echo "$dir"
