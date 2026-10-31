#!/usr/bin/env bash
# Pick a dir (zoxide, or fd with ctrl+f) and focus its herdr workspace, creating it if needed.
# With a dir argument, skip the picker and use that dir.
dir=${1:-}
[ -n "$dir" ] || dir=$(zoxide query -l | fzf --no-sort --border-label ' workspace ' --prompt '📁  ' \
  --color bg:#000000,bg+:#313244,gutter:#000000 \
  --header '  ^x zoxide ^f find' \
  --bind 'tab:down,btab:up' \
  --bind 'ctrl-x:change-prompt(📁  )+reload(zoxide query -l)' \
  --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)') || exit 0
dir=${dir%/}
label=$(basename "$dir")

id=$(herdr workspace list | jq -r --arg l "$label" '.result.workspaces[] | select(.label == $l) | .workspace_id' | head -1)
if [ -n "$id" ]; then
  herdr workspace focus "$id" >/dev/null
else
  herdr workspace create --cwd "$dir" --label "$label" --focus >/dev/null
fi
