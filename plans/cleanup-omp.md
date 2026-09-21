# Cleanup: remove omp (agent harness) from dotfiles

## Context
The omp agent harness has been uninstalled from the system (`which omp` → not found). The dotfiles repo still contains the `omp` stow package, README sections documenting it, and leftover symlinks/data in `~/.omp`. Goal: remove all omp traces from the repo and optionally purge the residual `~/.omp` data directory.

## Findings (from exploration)
- Binary gone: `omp`/`oh-my-posh` not on PATH, no `~/.config/oh-my-posh`.
- Repo: `omp/` stow package (52K) contains `AGENTS.md`, `config.yml`, `extensions/omp-ide/` (3 .ts files), `plugins/omp-plugins.lock.json` — all tracked by git (config.yml + lock file have uncommitted modifications).
- Live symlinks in `~/.omp/agent/`: `AGENTS.md`, `config.yml`, `extensions/` → point into `~/dotfiles/omp/`.
- `~/.omp` residual data outside the repo: `agent.db`, `blobs/`, `logs/`, `plugins/` (node_modules, installed_plugins.json), `cache/`, `puppeteer/`, `natives/`, `run/` daemons, `marketplaces.json`, `autoqa.db`, `install-id`, `gpu_cache.json`.
- README.md documents omp heavily (tree entry, `stow omp`, "omp-ide bridge" section, "omp plugins" section, plugin install commands).
- PLAN.md (untracked) is the old omp-ide → pi porting plan; already superseded (port is done, `pi/.pi/agent/extensions/pi-ide/` exists, untracked).
- Cosmetic omp mentions in comments only (no functionality):
  - `nvim/.config/nvim/lua/config/pi-queue.lua` ("omp or pi")
  - `nvim/.config/nvim/lua/plugins/pi-ide.lua` (header comment)
  - `pi/.pi/agent/extensions/pi-ide/package.json` + `index.ts` ("Port of the omp-ide extension")
  - `pi/.pi/agent/extensions/minimal-editor.ts` (borderless reference)
- No omp references in fish/hypr/tmux/foot/yazi/noctalia configs.
- Working tree already has unrelated dirty files (KEYMAPS.md, nvim pi-queue/pi-ide, untracked pi/ themes+extensions, plans/).

## User decisions
- Delete `~/.omp` entirely.
- Update cosmetic omp comments.
- Delete old untracked `PLAN.md` (superseded porting plan).
- Commit everything, including the unrelated pending changes (KEYMAPS.md, nvim pi-queue/pi-ide, untracked `pi/` extensions+themes, `plans/`).

## Approach
1. Unstow then delete the `omp` package (`stow -D omp`, then `git rm -r omp/`).
2. Strip omp sections/mentions from README.md.
3. Update cosmetic comments (nvim lua, pi extension files) to drop omp wording.
4. Delete residual `~/.omp` data directory (destructive, outside repo).
5. Delete old `PLAN.md`.
6. Commit everything (cleanup + unrelated pending changes).

## Files to modify
- `omp/` — delete entire directory (via `git rm -r`)
- `README.md` — remove omp tree entry, `stow omp` line, "omp-ide bridge" + "omp plugins" sections, plugin commands
- `nvim/.config/nvim/lua/config/pi-queue.lua` — comment wording (optional)
- `nvim/.config/nvim/lua/plugins/pi-ide.lua` — header comment (optional)
- `pi/.pi/agent/extensions/pi-ide/{package.json,index.ts}`, `pi/.pi/agent/extensions/minimal-editor.ts` — comment wording (optional)
- `PLAN.md` — delete (untracked)
- Outside repo: `~/.omp/` — delete

## Steps
- [x] `stow -D omp` (from ~/dotfiles) to remove `~/.omp/agent/{AGENTS.md,config.yml,extensions}` symlinks
- [x] `git rm -r omp/`
- [ ] Edit README.md: remove omp sections and tree entries
- [x] Update cosmetic omp comments in nvim/pi files
- [x] `rm -rf ~/.omp` (residual data — logs, db, plugins, cache)
- [x] `rm PLAN.md` (old porting plan)
- [ ] Commit everything: `git add -A` (omp deletion, README, comments, KEYMAPS.md, nvim, untracked pi/, plans/) then single commit

## Verification
- `stow -D` output clean; `ls ~/.omp` fails (directory gone)
- `grep -ri 'omp' ~/dotfiles` returns only expected hits (none, or historical plan docs if kept)
- `git status` shows omp/ deleted; commit created
- Fish shell starts without errors; nvim `pi-ide` still loads (comment-only changes)
