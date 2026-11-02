return {
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    init = function()
      -- called by lazygit's edit command; waits for the lazygit float to close, then splits
      -- shortcut: paths containing " or \ break the vim string, fix if that ever bites
      function _G.lazygit_edit(file, line)
        local tries = 0
        local function open()
          tries = tries + 1
          if vim.api.nvim_win_get_config(0).relative ~= "" and tries < 100 then
            return vim.defer_fn(open, 20)
          end
          vim.cmd.vsplit(vim.fn.fnameescape(file))
          if line then pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 }) end
        end
        open()
        return ""
      end
    end,
    opts = {
      lazygit = {
        enabled = true,
        win = { border = true }, -- outer border like other snacks floats; honors vim.o.winborder
        theme = {
          activeBorderColor          = { fg = "FloatBorder", bold = true },
          inactiveBorderColor        = { fg = "LazygitInactiveBorder" },
          searchingActiveBorderColor = { fg = "FloatBorder", bold = true },
          optionsTextColor           = { fg = "Function" },
          selectedLineBgColor        = { bg = "SnacksPickerListCursorLine" },
          defaultFgColor             = { fg = "Normal" },
          unstagedChangesColor       = { fg = "DiagnosticError" },
          cherryPickedCommitFgColor  = { fg = "Function" },
          cherryPickedCommitBgColor  = { fg = "Identifier" },
        },
        -- open files in a vsplit instead of the preset's new tab (q closes lazygit first)
        -- sh -c because lazygit runs these with $SHELL (fish)
        config = {
          os = {
            edit = [[sh -c 'nvim --server "$NVIM" --remote-send q && nvim --server "$NVIM" --remote-expr "v:lua.lazygit_edit(\"$1\")"' _ {{filename}}]],
            editAtLine = [[sh -c 'nvim --server "$NVIM" --remote-send q && nvim --server "$NVIM" --remote-expr "v:lua.lazygit_edit(\"$1\", $2)"' _ {{filename}} {{line}}]],
          },
        },
      },
      explorer = {
        replace_netrw = true, -- default; explicit because it changes nvim <dir> behavior
        trash = true,         -- default; CachyOS has gio
      },
      picker = {
        prompt = "❯ ",
        -- herdr command bar look: prompt on top, list, preview behind a divider
        layouts = {
          herdr = {
            layout = {
              box = "vertical",
              width = 0.8,
              min_width = 120,
              height = 0.8,
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "left",
              -- blank line under the input instead of a rule, like herdr
              { win = "input", height = 1, border = { "", "", "", "", "", " ", "", "" } },
              {
                -- hints on their own line inside the frame (bottom border of spaces)
                box = "vertical",
                border = { "", "", "", "", "", " ", "", "" },
                footer = "↑↓ move   ⏎ open   ⇥ select   M-p preview   M-h hidden   esc quit",
                footer_pos = "left",
                {
                  -- grey rule above the hints
                  box = "horizontal",
                  border = "bottom",
                  wo = { winhighlight = "FloatBorder:SnacksPickerPreviewBorder" },
                  { win = "list", border = "none" },
                  {
                    -- title over a rule, with the divider down the left
                    win = "preview",
                    title = "{preview}",
                    title_pos = "left",
                    width = 0.4,
                    border = { "│", "─", "", "", "", "", "", "│" },
                  },
                },
              },
            },
          },
        },
        layout = {
          preset = function() return vim.o.columns >= 120 and "herdr" or "vertical" end,
        },
        sources = {
          explorer = {
            hidden = true,   -- old neo-tree had hide_dotfiles = false
            ignored = true,  -- old neo-tree had hide_gitignored = false
            jump = { close = true }, -- float closes when a file is opened
            layout = { preset = "herdr", preview = true },
          },
          files = {
            hidden = true, -- fd --hidden: dot-dirs (.config, ...) included; .git still excluded
          },
          grep = {
            hidden = true, -- rg --hidden: dot-dirs searched; .git still excluded via --glob=!.git
          },
        },
      },
    },
    keys = {
      { "<leader>gg", function() require("snacks").lazygit() end, desc = "Lazygit" },
      { "<leader>e", function() require("snacks").explorer() end, desc = "File Explorer" },
      { "<leader>E", function() require("snacks").explorer.reveal() end, desc = "Reveal File in Explorer" },
      { "<leader>ff", function() require("snacks").picker.files() end, desc = "Find files" },
      { "<leader>fg", function() require("snacks").picker.grep() end, desc = "Live grep" },
      { "<leader>fb", function() require("snacks").picker.buffers() end, desc = "Buffers" },
      { "<leader>fk", function() require("snacks").picker.keymaps() end, desc = "Keymaps" },
      { "<leader>gc", function() require("snacks").picker.git_branches() end, desc = "Git branches" },
    },
  },
}
