#!/usr/bin/env bash
# Claude Code statusLine — mirrors your Starship prompt style
# Reads JSON from stdin

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

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
parts_out+="$(printf '\033[90m · ◆ %s\033[0m' "$model")"

# Caveman mode (state file holds level word; absent when off)
caveman_file="$HOME/.claude/.caveman-active"
if [ -f "$caveman_file" ]; then
    caveman_level=$(tr -d '[:space:]' < "$caveman_file")
    if [ -n "$caveman_level" ]; then
        parts_out+="$(printf '\033[90m · \033[0m\033[93m▲ %s\033[0m' "$caveman_level")"
    fi
fi

# Context usage (only when available)
if [ -n "$used_pct" ]; then
    printf -v used_int '%.0f' "$used_pct"
    parts_out+="$(printf '\033[90m · ◔ ctx:%s%%\033[0m' "$used_int")"
fi

# Rate limits (Claude.ai Pro/Max — present after first API response)
if [ -n "$five_h" ]; then
    printf -v five_int '%.0f' "$five_h"
    parts_out+="$(printf '\033[90m · ⧗ 5h:%s%%\033[0m' "$five_int")"
fi
if [ -n "$week" ]; then
    printf -v week_int '%.0f' "$week"
    parts_out+="$(printf '\033[90m · ⧗ 7d:%s%%\033[0m' "$week_int")"
fi

printf '%s' "$parts_out"
