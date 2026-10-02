#!/usr/bin/env bash
# bootstrap-node-links.sh — regenerate extensions/node_modules for this box.
#
# pi supplies host packages (typebox, @earendil-works/pi-ai, pi-agent-core,
# pi-tui, pi-coding-agent) to extensions at runtime via its own module
# mapping, so these links exist only for the TypeScript language server.
# They are machine-local (targets depend on where pi is installed) and
# gitignored; run this once per box after pulling the dotfiles.
#
# Usage: ./bootstrap-node-links.sh
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nm="$dir/node_modules"

# Locate the installed @earendil-works/pi-coding-agent package root.
pkg=""
if root="$(npm root -g 2>/dev/null)" &&
	[ -d "$root/@earendil-works/pi-coding-agent" ]; then
	pkg="$root/@earendil-works/pi-coding-agent"
else
	# Fallback: walk up from the real pi binary to the package root.
	real="$(readlink -f "$(command -v pi)")"
	d="$(dirname "$real")"
	while [ "$d" != "/" ]; do
		if [ -f "$d/package.json" ] &&
			grep -q '"name": "@earendil-works/pi-coding-agent"' "$d/package.json"; then
			pkg="$d"
			break
		fi
		d="$(dirname "$d")"
	done
fi

if [ -z "$pkg" ]; then
	echo "error: could not locate @earendil-works/pi-coding-agent (is pi installed?)" >&2
	exit 1
fi

nested="$pkg/node_modules"
for target in \
	"$pkg" \
	"$nested/@earendil-works/pi-tui" \
	"$nested/@earendil-works/pi-ai" \
	"$nested/@earendil-works/pi-agent-core" \
	"$nested/typebox"; do
	if [ ! -d "$target" ]; then
		echo "error: missing $target" >&2
		exit 1
	fi
done

rm -rf "$nm"
mkdir -p "$nm/@earendil-works"
ln -s "$pkg" "$nm/@earendil-works/pi-coding-agent"
ln -s "$nested/@earendil-works/pi-tui" "$nm/@earendil-works/pi-tui"
ln -s "$nested/@earendil-works/pi-ai" "$nm/@earendil-works/pi-ai"
ln -s "$nested/@earendil-works/pi-agent-core" "$nm/@earendil-works/pi-agent-core"
ln -s "$nested/typebox" "$nm/typebox"

echo "linked extensions/node_modules -> $pkg"