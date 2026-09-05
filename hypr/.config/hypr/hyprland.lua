-- CachyOS Hyprland Configuration

require("config.animations")
require("config.autostart")
require("config.colors")
require("config.decorations")
require("config.variables")
require("config.environment")
require("config.inputs")
require("config.binds")
require("config.misc")
require("config.monitors")
require("config.windowrules")
require("config.workspaces")


-- >>> HYPRLAND VISUAL EDITOR (HVE) <<<
pcall(function() dofile(os.getenv("HOME") .. "/.cache/noctalia/HVE/overlay.lua") end)
-- <<< HYPRLAND VISUAL EDITOR (HVE) <<<

pcall(require, "user-keybinds")
pcall(require, "user-config")
pcall(require, "user-rule")
