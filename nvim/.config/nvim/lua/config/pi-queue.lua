-- pi-queue: push the current selection/line to a connected omp session as a
-- `ref_queued` notification. omp owns the queue (no queue here) and
-- auto-clears it after each turn. Visual mode sends the selection range,
-- normal mode sends the current line.
--
-- Keymaps (prefix `c`):
--   <leader>ca  (visual)  send selection range as a ref
--   <leader>cA  (normal)  send current line as a ref
--   <leader>cx  (normal)  clear queued refs in omp
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

--- Send the current selection (visual) or current line (normal) to omp.
function M.add_ref()
  local s = server()
  if not s or not s.get_status().running then
    notify("pi-ide server not running", vim.log.levels.ERROR)
    return
  end
  if s.get_status().client_count == 0 then
    notify("No connected omp client (run /ide in omp)", vim.log.levels.WARN)
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
  notify("queued " .. label)
end
--- Clear any queued refs held by the connected omp client.
function M.clear()
  local s = server()
  if not s or not s.get_status().running then
    notify("pi-ide server not running", vim.log.levels.ERROR)
    return
  end
  if s.get_status().client_count == 0 then
    notify("No connected omp client (run /ide in omp)", vim.log.levels.WARN)
    return
  end
  s.broadcast("refs_cleared", {})
  notify("refs cleared")
end

return M
