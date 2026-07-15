local fn = require("hyprland.functions")

hl.config({
  misc = {
    disable_hyprland_logo = true,
  },
  general = { layout = "dwindle" },
  dwindle = {
    force_split = 2,
    preserve_split = true,
  },
})

hl.monitor({
  output = "DP-2",
  mode = "2560x1440@239.97",
  position = "0x0",
  scale = 1
})

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

hl.on("hyprland.start", function()
  hl.exec_cmd("fcitx5 -d")
  hl.exec_cmd("hyprctl reload")
end)

hl.bind("SUPER + H", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  hl.bind("h", hl.dsp.window.resize(fn.resize_active_window(-20, 0)), { repeating = true })
  hl.bind("l", hl.dsp.window.resize(fn.resize_active_window(20, 0)), { repeating = true })
  hl.bind("k", hl.dsp.window.resize(fn.resize_active_window(0, -20)), { repeating = true })
  hl.bind("j", hl.dsp.window.resize(fn.resize_active_window(0, 20)), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)
