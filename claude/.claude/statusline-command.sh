#!/usr/bin/env bash
# Claude Code statusLine — mirrors your Starship prompt style
# Reads JSON from stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory to ~
home="$HOME"
short_cwd="${cwd/#$home/\~}"

# Truncate to last 3 path segments (mirrors starship truncation_length=3)
IFS='/' read -ra parts <<< "$short_cwd"
count="${#parts[@]}"
if [ "$count" -gt 3 ]; then
    short_cwd="…/${parts[$count-3]}/${parts[$count-2]}/${parts[$count-1]}"
fi

# Git branch (skip optional locks to avoid blocking)
branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    branch=$(git -C "$cwd" -c gc.auto=0 symbolic-ref --short HEAD 2>/dev/null \
             || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)
fi

# Build status line
parts_out=""

# Directory segment (lavender-ish — ANSI bright magenta)
parts_out+="$(printf '\033[95m %s \033[0m' "$short_cwd")"

# Git branch segment
if [ -n "$branch" ]; then
    parts_out+="$(printf '\033[90m on \033[0m\033[94m %s\033[0m' "$branch")"
fi

# Model segment
parts_out+="$(printf '\033[90m · %s\033[0m' "$model")"

# Context usage (only when available)
if [ -n "$used_pct" ]; then
    printf -v used_int '%.0f' "$used_pct"
    parts_out+="$(printf '\033[90m · ctx:%s%%\033[0m' "$used_int")"
fi

# Caveman savings suffix (strip [CAVEMAN] badge, keep ⛏ savings)
caveman_script="$HOME/.claude/plugins/cache/caveman/caveman/ef6050c5e184/hooks/caveman-statusline.sh"
if [ -f "$caveman_script" ]; then
    caveman_out=$(bash "$caveman_script" 2>/dev/null)
    # Drop [CAVEMAN] or [CAVEMAN:MODE] with surrounding ANSI codes
    caveman_savings=$(printf '%s' "$caveman_out" \
        | sed -E $'s/\033\\[[0-9;]*m\\[CAVEMAN(:[A-Z0-9-]+)?\\]\033\\[0m ?//')
    [ -n "$caveman_savings" ] && parts_out+="$(printf '\033[90m · \033[0m')$caveman_savings"
fi

printf '%s' "$parts_out"
