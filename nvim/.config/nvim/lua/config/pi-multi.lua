-- pi-multi: accumulate selections across multiple files and send `path:line`
-- references (not raw text) to a running pi session via carderne/pi-nvim.
--
-- The built-in :Pi dialog sends one file's selection inline. This module keeps
-- a persistent queue so you can mark ranges in several files, then hand pi a
-- list of `path:start-end` locations it can read/edit itself.
local M = {}

local selections = {} -- { path, start_line, end_line, text? }

local function bufinfo()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then return nil end
  return {
    path = vim.fn.fnamemodify(name, ":p"), -- absolute: unambiguous for pi's read/edit
    short = vim.fn.fnamemodify(name, ":~:."),
  }
end

local function range_of(s)
  if s.start_line == s.end_line then
    return tostring(s.start_line)
  end
  return string.format("%d-%d", s.start_line, s.end_line)
end

local function push(start_line, end_line)
  local info = bufinfo()
  local e = { start_line = start_line, end_line = end_line }
  if info then
    e.path, e.short = info.path, info.short
  else
    -- unnamed buffer has no path to reference, so inline the text instead
    e.short = "[No Name]"
    e.text = table.concat(vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false), "\n")
  end
  table.insert(selections, e)
  vim.notify(string.format("pi: +%s:%s (%d queued)", e.short, range_of(e), #selections))
end

--- Queue an explicit line range in the current buffer.
function M.add(start_line, end_line)
  push(start_line, end_line)
end

--- Queue the whole current buffer.
function M.add_buffer()
  push(1, vim.api.nvim_buf_line_count(0))
end

--- Drop the queue.
function M.clear()
  selections = {}
  vim.notify("pi: queue cleared")
end

--- Show the current queue in a scratch buffer.
function M.list()
  if #selections == 0 then
    vim.notify("pi: queue is empty", vim.log.levels.INFO)
    return
  end
  local lines = {}
  for i, s in ipairs(selections) do
    table.insert(lines, string.format("%d. %s:%s", i, s.path or s.short, range_of(s)))
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_buf(0, buf)
end

local function build_message(question)
  local refs, inline = {}, {}
  for _, s in ipairs(selections) do
    if s.path then
      table.insert(refs, string.format("- %s:%s", s.path, range_of(s)))
    else
      table.insert(inline, string.format("=== %s (lines %s) ===\n%s", s.short, range_of(s), s.text))
    end
  end

  local parts = { question, "" }
  if #refs > 0 then
    table.insert(parts, "Locations:")
    for _, r in ipairs(refs) do table.insert(parts, r) end
  end
  if #inline > 0 then
    table.insert(parts, "")
    table.insert(parts, "Inline content (unnamed buffers):")
    table.insert(parts, table.concat(inline, "\n\n"))
  end
  return table.concat(parts, "\n")
end

--- Send the queued references + a prompt to pi.
function M.send()
  if #selections == 0 then
    vim.notify("pi: nothing queued (use :PiAdd)", vim.log.levels.WARN)
    return
  end
  local ok, pnvim = pcall(require, "pi-nvim")
  if not ok then
    vim.notify("pi-nvim plugin is not loaded", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = "Ask pi: " }, function(input)
    if not input then return end
    local msg = build_message(input)
    selections = {}
    pnvim.prompt(msg)
  end)
end

--- Register commands and keymaps.
function M.setup()
  vim.api.nvim_create_user_command("PiAdd", function(args)
    M.add(args.line1, args.line2)
  end, { range = true, desc = "Queue visual selection as file:line for pi" })

  vim.api.nvim_create_user_command("PiAddBuffer", M.add_buffer, { desc = "Queue current buffer as file:line for pi" })
  vim.api.nvim_create_user_command("PiSendRefs", M.send, { desc = "Send queued file:line refs to pi" })
  vim.api.nvim_create_user_command("PiClear", M.clear, { desc = "Clear queued pi refs" })
  vim.api.nvim_create_user_command("PiList", M.list, { desc = "List queued pi refs" })

  vim.keymap.set("v", "<leader>pa", ":PiAdd<CR>", { silent = true, desc = "Pi: add selection" })
  vim.keymap.set("n", "<leader>pA", "<cmd>PiAddBuffer<CR>", { desc = "Pi: add buffer" })
  vim.keymap.set("n", "<leader>ps", "<cmd>PiSendRefs<CR>", { desc = "Pi: send refs" })
  vim.keymap.set("n", "<leader>pc", "<cmd>PiClear<CR>", { desc = "Pi: clear refs" })
  vim.keymap.set("n", "<leader>pl", "<cmd>PiList<CR>", { desc = "Pi: list refs" })
end

return M
