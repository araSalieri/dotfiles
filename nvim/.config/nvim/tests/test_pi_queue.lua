-- Minimal self-check for config/pi-queue.lua, run headless from the repo:
--   nvim --headless -l nvim/.config/nvim/tests/test_pi_queue.lua
-- Spawns a fake pi socket server in /tmp/pi-nvim-sockets, then verifies
-- discovery, ping, ref queueing, and range logic.
local here = vim.fs.dirname(vim.fs.dirname(arg[0]))
package.path = here .. "/lua/?/init.lua;" .. package.path

local q = require("config.pi-queue")
local uv = vim.uv
local fails = 0
local done = false
local function check(name, cond)
	print(("  %-40s %s"):format(name, cond and "ok" or "FAIL"))
	if not cond then fails = fails + 1 end
end

-- Fake pi server: answers ping with pong, ref/prompt with ok.
local server = uv.new_tcp()
-- Fake server speaks over a unix socket via pipe handle.
local sock = uv.new_pipe(false)
local requests = {}
assert(sock:bind("/tmp/pi-nvim-sockets/fake-test.sock"))
assert(sock:listen(5, function(err)
	assert(not err, err)
	local client = uv.new_pipe(false)
	sock:accept(client)
	local buf = ""
	client:read_start(function(rd_err, data)
		if data then
			buf = buf .. data
			local nl = buf:find("\n")
			if nl then
				local msg = vim.json.decode(buf:sub(1, nl - 1))
				table.insert(requests, msg)
				local resp
				if msg.type == "ping" then
					resp = { ok = true, type = "pong" }
				else
					resp = { ok = true }
				end
				client:write(vim.json.encode(resp) .. "\n")
			end
		end
	end)
end))
-- Manifest so discovery finds it. cwd = this process's cwd, so it wins over
-- any real pi session running elsewhere; test traffic never touches it.
local f = io.open("/tmp/pi-nvim-sockets/fake-test.sock.info", "w")
f:write(vim.json.encode({ socket = "/tmp/pi-nvim-sockets/fake-test.sock", cwd = vim.uv.cwd(), pid = 1 }))
f:close()

-- libuv defers socket-file creation to the loop; tick it.
vim.wait(100)

-- 1. Discovery picks the cwd-matching socket.
local path = q.get_socket_path()
check("discovery: cwd match wins", path == "/tmp/pi-nvim-sockets/fake-test.sock")

-- 2. Ping round-trip.
q.send_raw({ type = "ping" }, function(err, resp)
	check("ping round-trip", err == nil and resp and resp.type == "pong")

	-- 3. Ref queued (payload shape).
	q.send_raw({ type = "ref", filePath = "/tmp/x.lua", startLine = 4, endLine = 9 }, function()
		-- 4. Prompt round-trip.
		q.send_raw({ type = "prompt", message = "hi" }, function()
			check("ref accepted", #requests >= 2 and requests[2].type == "ref"
				and requests[2].startLine == 4 and requests[2].endLine == 9)
			check("prompt accepted", #requests >= 3 and requests[3].type == "prompt"
				and requests[3].message == "hi")

			-- 5. _range from '< /'> marks (normal mode, no visual).
			vim.fn.setpos("'<", { 0, 3, 1, 0 })
			vim.fn.setpos("'>", { 0, 7, 1, 0 })
			local s, e, was_v = q._range()
			check("range from marks", s == 2 and e == 6 and was_v == false)

			-- 6. _range nil with no marks.
			vim.fn.setpos("'<", { 0, 0, 0, 0 })
			vim.fn.setpos("'>", { 0, 0, 0, 0 })
			check("range nil without marks", q._range() == nil)

			done = true
		end)
	end)
end)

vim.wait(10000, function() return done end)
sock:close()
os.remove("/tmp/pi-nvim-sockets/fake-test.sock.info")
print(fails == 0 and "ALL PASS" or (fails .. " FAILED"))
vim.cmd("cq " .. (fails == 0 and 0 or 1))
