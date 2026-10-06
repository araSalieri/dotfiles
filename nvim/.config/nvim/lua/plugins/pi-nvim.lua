-- pi-nvim: one-way bridge from nvim into a running pi session. No plugin --
-- the socket client lives in config/pi-queue.lua and the listener is the
-- dotfiles pi extension pi/.pi/agent/extensions/pi-nvim.ts.
--
-- Queue mode (like the old pi-ide integration): <leader>ca queues the
-- selection/line, <leader>cf queues picker files or the current buffer as
-- `@path:lines` refs that accumulate in pi's editor input until the message
-- is sent. Immediate sends (prompt/file/selection/buffer) bypass the queue.
return {
  {
    "dotfiles/pi-queue",
    dir = vim.fn.stdpath("config") .. "/lua",
    name = "pi-queue",
    lazy = false,
    config = function()
      local q = require("config.pi-queue")
      q.setup()

      vim.api.nvim_create_user_command("PiPrompt", function(opts)
        q.prompt(opts.args ~= "" and opts.args or nil)
      end, { nargs = "?", desc = "Send a prompt to pi" })

      vim.api.nvim_create_user_command("PiSendFile", function()
        q.send_file()
      end, { desc = "Send current file to pi with a prompt" })

      vim.api.nvim_create_user_command("PiSendSelection", function()
        q.send_selection()
      end, { range = true, desc = "Send visual selection to pi with a prompt" })

      vim.api.nvim_create_user_command("PiSendBuffer", function()
        q.send_buffer()
      end, { desc = "Send entire buffer to pi with a prompt" })

      vim.api.nvim_create_user_command("PiQueueRef", function()
        q.add_ref()
      end, { desc = "Queue selection/line as a ref in pi's input" })

      vim.api.nvim_create_user_command("PiQueueFile", function()
        q.file_ref()
      end, { desc = "Queue picker files or current buffer as refs in pi's input" })

      vim.api.nvim_create_user_command("PiPing", function()
        q.ping()
      end, { desc = "Ping the pi session" })
    end,
  },
}
