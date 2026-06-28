hl.window_rule({
  name = "disable-discord-special",
  match = { class = "discord" },
  workspace = "unset",
})

hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
  dwindle = {
    force_split = 2,
  }
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
end)
