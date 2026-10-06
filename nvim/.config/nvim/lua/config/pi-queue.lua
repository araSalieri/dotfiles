-- pi-queue: our own one-way bridge from nvim into a running pi session
-- (companion to pi/.pi/agent/extensions/pi-nvim.ts, which listens on the
-- other end). Replaces the carderne/pi-nvim plugin.
--
-- Queue mode mimics the old pi-ide integration: refs accumulate as
-- `@path:lines` tokens in pi's editor input and are consumed by the model
-- when the message is sent. Immediate sends (prompt/file/selection/buffer)
-- bypass the queue and go straight to the agent as a follow-up.
--
-- Keymaps (see config/keymaps.lua):
--   <leader>ca  (visual)  queue the selection range as a ref
--               (normal)  queue the current line as a ref
--   <leader>cf  (normal)  queue file(s) selected in the active snacks
--                         picker/explorer, or the current buffer's file
local M = {}

local SOCKETS_DIR = "/tmp/pi-nvim-sockets"

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO, { title = "pi-queue" })
end

function M.get_socket_path()
	local ok, files = pcall(vim.fn.glob, SOCKETS_DIR .. "/*.info", false, true)
	if not ok or not files then return nil end

	local best_sock, best_mtime = nil, 0
	local any_sock, any_mtime = nil, 0
	for _, info_path in ipairs(files) do
		local content_ok, content = pcall(vim.fn.readfile, info_path)
		if content_ok and content and content[1] then
			local parsed_ok, info = pcall(vim.json.decode, content[1])
			if parsed_ok and info then
				local sock_file = info_path:sub(1, -6) -- strip ".info"
				local stat = vim.uv.fs_stat(sock_file)
				if stat then
					local addr = info.socket or sock_file
					if stat.mtime.sec > any_mtime then
						any_mtime = stat.mtime.sec
						any_sock = addr
					end
					if info.cwd == vim.uv.cwd() and stat.mtime.sec > best_mtime then
						best_mtime = stat.mtime.sec
						best_sock = addr
					end
				end
			end
		end
	end
	if best_sock then return best_sock end
	if any_sock then return any_sock end

	local latest = "/tmp/pi-nvim-latest.sock"
	if vim.uv.fs_stat(latest) then return latest end
	return nil
end

--- Send a JSON message to the pi socket; cb(err, response) with parsed reply.
function M.send_raw(msg, cb)
	local sock_path = M.get_socket_path()
	if not sock_path then
		local err = "No pi session found. Is pi running?"
		notify(err, vim.log.levels.ERROR)
		if cb then cb(err, nil) end
		return
	end

	local client = vim.uv.new_pipe(false)
	if not client then
		if cb then cb("Failed to create pipe", nil) end
		return
	end

	client:connect(sock_path, function(err)
		if err then
			vim.schedule(function()
				notify("Failed to connect to pi: " .. err, vim.log.levels.ERROR)
				if cb then cb(err, nil) end
			end)
			return
		end

		client:write(vim.json.encode(msg) .. "\n")
		local buf = ""
		client:read_start(function(read_err, data)
			if read_err then
				client:close()
				vim.schedule(function()
					if cb then cb(read_err, nil) end
				end)
				return
			end
			if data then
				buf = buf .. data
				local nl = buf:find("\n")
				if nl then
					local line = buf:sub(1, nl - 1)
					client:read_stop()
					client:close()
					vim.schedule(function()
						local ok, resp = pcall(vim.json.decode, line)
						-- NB: `ok and nil or err` is a trap here — `true and nil` is
						-- nil, so the or-branch always wins. Branch explicitly.
						if not ok or type(resp) ~= "table" then
							if cb then cb("Invalid response from pi", nil) end
						else
							if cb then cb(nil, resp) end
						end
					end)
				end
			else
				-- EOF before a reply arrived.
				client:close()
				if cb then cb("pi closed the connection", nil) end
			end
		end)
	end)
end

-- Private helpers exposed only for tests.

--- Current selection range as 0-based start_line, end_line and was_visual,
--- or nil when neither an active visual mode nor '< '/'> ' marks exist.
--- In visual mode reads the 'v'/'.' marks; falls back to '< '/'> ' marks.
function M._range()
	local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
	if mode == "v" or mode == "V" or mode == "\22" then
		local a = vim.fn.getpos("v")
		local b = vim.fn.getpos(".")
		if a[2] > b[2] or (a[2] == b[2] and a[3] > b[3]) then a, b = b, a end
		return a[2] - 1, b[2] - 1, true
	end
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	if start_pos[2] == 0 or end_pos[2] == 0 then return nil end
	return start_pos[2] - 1, end_pos[2] - 1, false
end

local function current_path()
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		notify("Buffer has no file name", vim.log.levels.WARN)
		return nil
	end
	return path
end

local function relative(path)
	local cwd = vim.fn.getcwd()
	if vim.startswith(path, cwd) then
		return vim.fn.fnamemodify(path, ":.")
	end
	return path
end

--- Queue the current selection (visual) or current line (normal) as a ref.
function M.add_ref()
	local start_line, end_line, was_visual = M._range()
	if not start_line then
		notify("No selection or previous visual range", vim.log.levels.WARN)
		return
	end
	local path = current_path()
	if not path then return end

	M.send_raw({
		type = "ref",
		filePath = path,
		startLine = start_line,
		endLine = end_line,
	}, function(err, resp)
		if err or not (resp and resp.ok) then
			notify("pi error: " .. (err or (resp and resp.error) or "unknown"), vim.log.levels.ERROR)
			return
		end
		local label = start_line == end_line
			and string.format("%s:%d", relative(path), start_line + 1)
			or string.format("%s:%d-%d", relative(path), start_line + 1, end_line + 1)
		notify("queued " .. label)
	end)

	-- Clear the visual selection after a successful send.
	if was_visual then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
	end
end

--- Queue the file(s) selected in the active snacks picker/explorer as
--- whole-file refs (honors multi-select); falls back to the current buffer.
function M.file_ref()
	local ok, snacks = pcall(require, "snacks.picker")
	local pickers = ok and snacks.get() or {}
	local picker = pickers[#pickers]
	if not picker then
		local path = current_path()
		if not path then return end
		M.send_raw({ type = "ref", filePath = path }, function(err, resp)
			if err or not (resp and resp.ok) then
				notify("pi error: " .. (err or (resp and resp.error) or "unknown"), vim.log.levels.ERROR)
				return
			end
			notify("queued @" .. relative(path))
		end)
		return
	end

	local items = picker:selected({ fallback = true })
	local paths = {}
	for _, item in ipairs(items) do
		if item.file and item.file ~= "" then
			table.insert(paths, item.file)
		end
	end
	if #paths == 0 then
		notify("No files selected in picker", vim.log.levels.WARN)
		return
	end
	for _, path in ipairs(paths) do
		M.send_raw({ type = "ref", filePath = path }, function() end)
	end
	notify(("queued %d file ref(s)"):format(#paths))
end

--- Send a prompt immediately. With no message, prompts for input.
function M.prompt(message)
	if not message then
		vim.ui.input({ prompt = "Pi prompt: " }, function(input)
			if input and input ~= "" then M.prompt(input) end
		end)
		return
	end
	M.send_raw({ type = "prompt", message = message }, function(err, resp)
		if err or not (resp and resp.ok) then
			notify("pi error: " .. (err or (resp and resp.error) or "unknown"), vim.log.levels.ERROR)
			return
		end
		notify("Sent to pi", vim.log.levels.INFO)
	end)
end

local function with_selection(cb)
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")
	-- getregion errors (E475) when visualmode() is "" (command run without
	-- an active visual mode); fall back to plain line extraction.
	local ok, lines = pcall(vim.fn.getregion, start_pos, end_pos, { type = vim.fn.visualmode() })
	if not ok or not lines then
		if start_pos[2] > 0 and end_pos[2] >= start_pos[2] then
			lines = vim.api.nvim_buf_get_lines(0, start_pos[2] - 1, end_pos[2], false)
		else
			lines = {}
		end
	end
	local selection = table.concat(lines, "\n")
	if selection == "" then
		notify("Empty selection", vim.log.levels.WARN)
		return
	end
	cb(selection, start_pos[2], end_pos[2])
end

--- Send the visual selection with a prompt (immediate).
function M.send_selection()
	with_selection(function(selection, start_line, end_line)
		local file, ft = relative(vim.fn.expand("%:p")), vim.bo.filetype
		vim.ui.input({ prompt = "Pi prompt (selection): " }, function(input)
			if not input then return end
			local header = string.format("%s lines %d-%d", file, start_line, end_line)
			local message
			if input == "" then
				message = string.format("Look at this code from %s:\n\n```%s\n%s\n```", header, ft, selection)
			else
				message = string.format("%s\n\nFrom %s:\n```%s\n%s\n```", input, header, ft, selection)
			end
			M.prompt(message)
		end)
	end)
end

--- Send the current file with a prompt (immediate).
function M.send_file()
	local file = vim.fn.expand("%:p")
	if file == "" then
		notify("No file open", vim.log.levels.WARN)
		return
	end
	vim.ui.input({ prompt = "Pi prompt (file: " .. vim.fn.expand("%:.") .. "): " }, function(input)
		if not input then return end
		local message
		if input == "" then
			message = string.format("Look at this file: %s", file)
		else
			message = string.format("File: %s\n\n%s", file, input)
		end
		M.prompt(message)
	end)
end

--- Send the entire buffer with a prompt (immediate).
function M.send_buffer()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local content = table.concat(lines, "\n")
	local file, ft = relative(vim.fn.expand("%:p")), vim.bo.filetype
	vim.ui.input({ prompt = "Pi prompt (buffer): " }, function(input)
		if not input then return end
		local message
		if input == "" then
			message = string.format("Look at this file %s:\n\n```%s\n%s\n```", file, ft, content)
		else
			message = string.format("%s\n\nFile: %s\n```%s\n%s\n```", input, file, ft, content)
		end
		M.prompt(message)
	end)
end

--- Ping the pi session to check connectivity.
function M.ping()
	M.send_raw({ type = "ping" }, function(err, resp)
		if err then
			notify("Pi not reachable: " .. err, vim.log.levels.ERROR)
		elseif resp and resp.type == "pong" then
			notify("Pi is alive!", vim.log.levels.INFO)
		else
			notify("Unexpected response from pi", vim.log.levels.WARN)
		end
	end)
end

--- Auto-reload buffers changed externally (e.g. by the pi agent's tools).
--- Only polls when a pi session is reachable; respects existing autoread.
function M.setup()
	if not vim.o.autoread then vim.o.autoread = true end
	local timer = vim.uv.new_timer()
	timer:start(0, 1000, vim.schedule_wrap(function()
		if M.get_socket_path() then
			pcall(vim.cmd, "silent! checktime")
		end
	end))
end

return M
