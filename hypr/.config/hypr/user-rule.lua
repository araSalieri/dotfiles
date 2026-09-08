hl.window_rule({ match = { class = "steam" }, workspace = "name:gaming", float = false })

-- Yellow border on special workspace windows (visual cue for SUPER+S scratchpad)
hl.window_rule({ match = { workspace = "special:ara" }, border_color = { colors = { "rgba(186, 142, 35, 1)" } } })
