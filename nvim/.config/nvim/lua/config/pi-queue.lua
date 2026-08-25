-- pi-queue: collect `file:line` / `file:start:end` references and push them to
-- a connected pi-ide client. The @ldelossa/pi-ide extension only understands
-- one editor->pi channel: the `selection_changed` notification (which it
-- injects into the agent context as an <editor> block). We reuse it so queued
-- refs land in pi's context as a visible <selection> on the next run.
--
-- A multi-line selection is stored as ONE range ref (`file:start:end`) rather
-- than one entry per line; a single line is `file:line`.
--
-- Keymaps (prefix `c`, since `p` read as "paste" and `ca`/`cc` are taken):
--   <leader>ca  (visual)  queue selection as file:line / file:start:end
--   <leader>cA  (normal)  queue current line as file:line
--   <leader>cs  (normal)  send queued refs to pi
--   <leader>cl  (normal)  list queued refs
--   <leader>cx  (normal)  clear queued refs
local M = {}

local queue = {} -- { { path = ..., start = ..., last = ... }, ... }

-- Fall back to a scrollable floating window once the queue exceeds this many
-- refs (a notification would overflow the command-line area).
local FLOAT_THRESHOLD = 12

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "pi-queue" })
end

-- Resolve the pi-ide server module if it is loaded (plugin is `lazy = false`).
-- IMPORTANT: must match the plugin's own require name `pi-ide.server.init`.
-- `require("pi-ide.server")` loads the same file but caches it under a
-- different key, producing a *fresh* module whose server state is nil -- which
-- reports "server not running" even when pi is connected.
local function server()
  local ok, s = pcall(require, "pi-ide.server.init")
  return ok and s or nil
end

local function relative(path)
  local cwd = vim.fn.getcwd()
  if vim.startswith(path, cwd) then
    return vim.fn.fnamemodify(path, ":.")
  end
  return path
end

local function is_visual()
  local mode = vim.api.nvim_get_mode().mode
  return mode:sub(1, 1) == "v" or mode:sub(1, 1) == "V" or mode:sub(1, 1) == "\22"
end

local function current_path()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    notify("Buffer has no file name", vim.log.levels.WARN)
    return nil
  end
  return path
end

-- `file:line` for a single line, `file:start:end` for a range.
local function ref_label(ref)
  if ref.start == ref.last then
    return string.format("%s:%d", relative(ref.path), ref.start)
  end
  return string.format("%s:%d:%d", relative(ref.path), ref.start, ref.last)
end

--- Queue the current visual selection as a single range ref (visual mode).
function M.queue_selection()
  if not is_visual() then
    notify("Queue selection works in visual mode", vim.log.levels.WARN)
    return
  end
  local path = current_path()
  if not path then return end

  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")
  if s[2] > e[2] or (s[2] == e[2] and s[3] > e[3]) then s, e = e, s end

  queue[#queue + 1] = { path = path, start = s[2], last = e[2] }
  notify("queued " .. ref_label(queue[#queue]) .. " (" .. #queue .. " total)")
end

--- Queue the current cursor line as a single-line ref (normal mode).
function M.queue_current()
  local path = current_path()
  if not path then return end
  local line = vim.api.nvim_win_get_cursor(0)[1]
  queue[#queue + 1] = { path = path, start = line, last = line }
  notify("queued " .. ref_label(queue[#queue]) .. " (" .. #queue .. " total)")
end

--- Push queued refs to the connected pi client as a selection_changed notification.
function M.send()
  if #queue == 0 then
    notify("Queue is empty", vim.log.levels.WARN)
    return
  end
  local s = server()
  if not s or not s.get_status().running then
    notify("pi-ide server not running", vim.log.levels.ERROR)
    return
  end
  if s.get_status().client_count == 0 then
    notify("No connected pi client (run `/ide` in pi)", vim.log.levels.WARN)
    return
  end

  local lines = {}
  local min_line, max_line = math.huge, -math.huge
  local seen_files = {}
  for _, ref in ipairs(queue) do
    lines[#lines + 1] = ref_label(ref)
    if ref.start < min_line then min_line = ref.start end
    if ref.last > max_line then max_line = ref.last end
    seen_files[ref.path] = true
  end

  local n_files = 0
  for _ in pairs(seen_files) do n_files = n_files + 1 end
  table.insert(lines, 1, string.format("pi-queue: %d ref(s) across %d file(s)", #queue, n_files))

  -- The extension renders the wrapper as `lines="<start+1>-<end+1>"`. A batch
  -- of refs isn't a single contiguous selection, so span the label across the
  -- referenced line range (exact for a single file) instead of the cursor.
  local payload = {
    text = table.concat(lines, "\n"),
    filePath = queue[1].path,
    selection = {
      start = { line = min_line - 1, character = 0 },
      ["end"] = { line = max_line - 1, character = 0 },
      isEmpty = false,
    },
  }

  local sent = #queue
  if s.broadcast("selection_changed", payload) then
    queue = {}
    notify("Sent " .. sent .. " ref(s) to pi (queue cleared)")
  else
    notify("Failed to send to pi", vim.log.levels.ERROR)
  end
end

local function list_lines()
  if #queue == 0 then return { "empty" } end
  local lines = { #queue .. " ref(s)" }
  for i, ref in ipairs(queue) do
    lines[#lines + 1] = string.format("%d. %s", i, ref_label(ref))
  end
  return lines
end

--- Show queued refs: notification for short queues, scrollable float for long ones.
function M.list()
  if #queue == 0 then
    notify("empty")
    return
  end

  local lines = list_lines()
  if #queue <= FLOAT_THRESHOLD then
    notify(table.concat(lines, "\n"))
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  width = math.min(math.max(width + 2, 28), vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 6)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " pi-queue ",
    title_pos = "center",
  })

  local close = function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Close" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, desc = "Close" })
end

--- Empty the queue.
function M.clear()
  if #queue == 0 then
    notify("Queue is already empty", vim.log.levels.INFO)
    return
  end
  queue = {}
  notify("Queue cleared")
end

return M
