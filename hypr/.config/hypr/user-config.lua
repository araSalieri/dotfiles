hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 1,
    col = {
      active_border = {
        colors = { "rgba(00000000)" },
      },
      inactive_border = "rgba(0,0,0,1)",
    },
  },
  decoration = {
    rounding = 15,
  },
  dwindle = {
    force_split = 2,
  },
})

hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+)$",
  },
  no_anim = true,
  ignore_alpha = 0.5,
  blur = true,
  blur_popups = true,
})

hl.env("QT_IM_MODULE", "fcitx")
hl.env("XMODIFIERS", "@im=fcitx")
hl.env("SDL_IM_MODULE", "fcitx")

hl.on("hyprland.start", function()
  hl.exec_cmd("fcitx5 -d")
end)
