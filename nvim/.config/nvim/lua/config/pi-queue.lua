-- pi-queue: push the current selection/line to a connected agent session as a
-- `ref_queued` notification. The agent appends an `@path:lines` ref to its
-- editor input (Claude Code nvim style); refs are consumed when the message
-- is sent. Visual mode sends
-- the selection range, normal mode sends the current line.
--
-- Keymaps (prefix `c`):
--   <leader>ca  (visual)  send selection range as a ref
--   <leader>cf  (picker/buffer)  send file(s) selected in snacks picker/explorer,
--                                or the current buffer's file, as full-file refs
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "pi-queue" })
end

-- Resolve the pi-ide server module if it is loaded (plugin is `lazy = false`).
-- IMPORTANT: must match the plugin's own require name `pi-ide.server.init`.
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

--- Send the current selection (visual) or current line (normal) to the connected agent.
function M.add_ref()
  local s = server()
  if not s or not s.get_status().running then
    notify("pi-ide server not running", vim.log.levels.ERROR)
    return
  end
  if s.get_status().client_count == 0 then
    notify("No connected agent client (run /ide in the agent)", vim.log.levels.WARN)
    return
  end

  local path = current_path()
  if not path then return end

  local start_line, end_line
  if is_visual() then
    local a = vim.fn.getpos("v")
    local b = vim.fn.getpos(".")
    if a[2] > b[2] or (a[2] == b[2] and a[3] > b[3]) then a, b = b, a end
    start_line = a[2] - 1
    end_line = b[2] - 1
  else
    start_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    end_line = start_line
  end

  s.broadcast("ref_queued", {
    filePath = path,
    startLine = start_line,
    endLine = end_line,
  })
  local label = start_line == end_line
    and string.format("%s:%d", relative(path), start_line + 1)
    or string.format("%s:%d-%d", relative(path), start_line + 1, end_line + 1)
  notify("sent " .. label .. " to pi input")
end

--- Send the file(s) currently selected in the active snacks picker/explorer
--- window as full-file refs (one per file). Honors multi-select. With no
--- active picker, falls back to the current buffer's file.
function M.file_ref()
  local s = server()
  if not s or not s.get_status().running then
    notify("pi-ide server not running", vim.log.levels.ERROR)
    return
  end
  if s.get_status().client_count == 0 then
    notify("No connected agent client (run /ide in the agent)", vim.log.levels.WARN)
    return
  end

  local ok, snacks = pcall(require, "snacks.picker")
  local pickers = ok and snacks.get() or {}
  local picker = pickers[#pickers]
  if not picker then
    -- No active picker: send the current buffer's file instead.
    local path = current_path()
    if not path then return end
    s.broadcast("ref_queued", { filePath = path })
    notify("sent " .. relative(path) .. " to pi input")
    return
  end

  local items = picker:selected({ fallback = true })
  local count = 0
  for _, item in ipairs(items) do
    local path = item.file
    if path and path ~= "" then
      -- Whole-file ref: filePath only, no line range (pi renders `@path`).
      s.broadcast("ref_queued", { filePath = path })
      count = count + 1
    end
  end
  notify("sent " .. count .. " file ref(s) to pi input")
end

return M
