local mainMod = "SUPER"
local noctCall = "noctalia msg "
local launchPrefix = "uwsm app -- "

-- Bind Screenshoot
hl.unbind(mainMod .. " + SHIFT + S")
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(noctCall .. "screenshot-region"))

-- Bind Terminal to T
hl.unbind(mainMod .. " + T")
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(launchPrefix .. TERMINAL))

-- Unbind Fullscreen, Calculator
hl.unbind(mainMod .. " + D")
hl.unbind(mainMod .. " + C")

-- Bind Workspace move
for i = 1, NUM_WPM do
  local key = i % 10

  -- remove template absolute-focus binds (SUPER + ALT + key)
  hl.unbind(mainMod .. " + ALT + " .. key)

  -- remove template move-to-monitor binds (SUPER + SHIFT + key)
  hl.unbind(mainMod .. " + SHIFT + " .. key)

  -- add new bind to move workspace
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Bind Special Workspace
hl.unbind(mainMod .. " + S")
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("ara"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:ara" }))

-- hl.bind(mainMod .. " + G", hl.dsp.workspace.toggle_special("steam"))
-- hl.bind(mainMod .. " + G", hl.dsp.exec_cmd([[
--   if hyprctl clients | grep -q 'class: steam'; then
--     hyprctl dispatch togglespecialworkspace steam
--   else
--     (steam &) ; hyprctl dispatch togglespecialworkspace steam
--   fi
-- ]]))

-- Monitor focus/move, shifted off SHIFT+num (which is now absolute focus):
hl.bind(mainMod .. " + CONTROL + ALT + 1", hl.dsp.focus({ monitor = MONITOR1 }))
hl.bind(mainMod .. " + CONTROL + ALT + 2", hl.dsp.focus({ monitor = MONITOR2 }))
hl.bind(mainMod .. " + CONTROL + ALT + 3", hl.dsp.focus({ monitor = MONITOR3 }))
hl.unbind(mainMod .. " + SHIFT + CONTROL + 1")
hl.unbind(mainMod .. " + SHIFT + CONTROL + 2")
hl.unbind(mainMod .. " + SHIFT + CONTROL + 3")
hl.bind(mainMod .. " + SHIFT + CONTROL + 1", hl.dsp.window.move({ monitor = MONITOR1 }))
hl.bind(mainMod .. " + SHIFT + CONTROL + 2", hl.dsp.window.move({ monitor = MONITOR2 }))
hl.bind(mainMod .. " + SHIFT + CONTROL + 3", hl.dsp.window.move({ monitor = MONITOR3 }))
