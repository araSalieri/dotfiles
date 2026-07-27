local fn = require("utils.functions")

hl.config({
  ecosystem = {
    no_donation_nag = true,
    no_update_news = true,
  },
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

hl.monitor({
  output = "eDP-1",
  mode = "2880x1800@120",
  position = "0x0",
  scale = 1.33
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "auto",
  scale = 1,
  mirror = "eDP-1"
})

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

hl.on("hyprland.start", function()
  hl.exec_cmd("fcitx5 -d")
end)

hl.bind("SUPER + H", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
  hl.bind("h", fn.resize_active_window(-20, 0), { repeating = true })
  hl.bind("l", fn.resize_active_window(20, 0), { repeating = true })
  hl.bind("k", fn.resize_active_window(0, -20), { repeating = true })
  hl.bind("j", fn.resize_active_window(0, 20), { repeating = true })
  hl.bind("escape", hl.dsp.submap("reset"))
end)
