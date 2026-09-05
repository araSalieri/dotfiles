hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 1,
    col = {
      active_border = {
        colors = { CACHYGREY },
      },
      inactive_border = "rgba(00000000)",
    },
  },
  decoration = {
    rounding = 15,
  },
})

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

hl.on("hyprland.start", function()
  hl.exec_cmd("fcitx5 -d")
end)
