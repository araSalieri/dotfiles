-- Headless tests for config/pi-queue.lua `file_ref` (snacks picker/explorer refs).
-- Run: nvim --headless -u NONE -l nvim/.config/nvim/tests/test_pi_queue.lua
--
-- Stubs `pi-ide.server.init` and `snacks.picker` before loading the module, then
-- asserts the ref_queued broadcast payloads.

local function fail(msg)
  io.stderr:write("FAIL: " .. msg .. "\n")
  os.exit(1)
end

local broadcasts = {}
package.loaded["pi-ide.server.init"] = {
  get_status = function()
    return { running = true, client_count = 1 }
  end,
  broadcast = function(method, params)
    broadcasts[#broadcasts + 1] = { method = method, params = params }
  end,
}

local picker_items = {}
package.preload["snacks.picker"] = function()
  return {
    get = function()
      if #picker_items == 0 then return {} end
      return {
        { selected = function(_)
          return picker_items
        end },
      }
    end,
  }
end

-- Temp file fixture (line count is irrelevant: refs are range-less).
local tmp = os.tmpname() .. ".lua"
local f = assert(io.open(tmp, "w"))
f:write("one\n\ntwo\nthree\nfour\nfive\n")
f:close()

local module = dofile("nvim/.config/nvim/lua/config/pi-queue.lua")

-- 1. Single file: full-file ref (filePath only, no line range).
picker_items = { { file = tmp } }
module.file_ref()
if #broadcasts ~= 1 then fail("expected 1 broadcast, got " .. #broadcasts) end
local b = broadcasts[1]
if b.method ~= "ref_queued" then fail("method was " .. tostring(b.method)) end
if b.params.filePath ~= tmp then fail("filePath mismatch: " .. tostring(b.params.filePath)) end
if b.params.startLine ~= nil then fail("unexpected startLine: " .. tostring(b.params.startLine)) end
if b.params.endLine ~= nil then fail("unexpected endLine: " .. tostring(b.params.endLine)) end

-- 2. Multi-select: one ref per selected item, in order.
broadcasts = {}
picker_items = { { file = tmp }, { file = tmp } }
module.file_ref()
if #broadcasts ~= 2 then fail("multi-select: expected 2 broadcasts, got " .. #broadcasts) end

-- 3. No active picker + unnamed buffer: no broadcast (current_path warns).
broadcasts = {}
picker_items = {}
module.file_ref()
if #broadcasts ~= 0 then fail("expected no broadcast for unnamed buffer without picker") end

-- 4. No active picker + named buffer: falls back to current buffer file,
--    broadcast as range-less ref.
broadcasts = {}
picker_items = {}
vim.api.nvim_buf_set_name(0, tmp)
module.file_ref()
if #broadcasts ~= 1 then fail("buffer fallback: expected 1 broadcast, got " .. #broadcasts) end
local b2 = broadcasts[1]
if b2.method ~= "ref_queued" then fail("fallback method was " .. tostring(b2.method)) end
if b2.params.filePath ~= tmp then fail("fallback filePath mismatch: " .. tostring(b2.params.filePath)) end
if b2.params.startLine ~= nil then fail("fallback unexpected startLine: " .. tostring(b2.params.startLine)) end
if b2.params.endLine ~= nil then fail("fallback unexpected endLine: " .. tostring(b2.params.endLine)) end
vim.api.nvim_buf_set_name(0, "")

-- 5. Item without a file field: skipped.
broadcasts = {}
picker_items = { { text = "no file" } }
module.file_ref()
if #broadcasts ~= 0 then fail("expected no broadcast for item without file") end

-- 6. Server not running: no broadcast.
package.loaded["pi-ide.server.init"].get_status = function()
  return { running = false, client_count = 0 }
end
broadcasts = {}
picker_items = { { file = tmp } }
module.file_ref()
if #broadcasts ~= 0 then fail("expected no broadcast when server is down") end

os.remove(tmp)
io.write("PASS: all pi-queue file_ref tests\n")
