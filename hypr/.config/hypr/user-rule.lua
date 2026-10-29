hl.window_rule({ match = { workspace = "special:ara" }, border_color = { colors = { "rgba(186, 142, 35, 1)" } } })

hl.window_rule({ match = { class = "^(steam)$" }, workspace = "name:steam", border_color = { colors = { "rgba(0, 30, 66, 1.0)" } } })

-- Steam dropdown menus are floating windows; undo the stock "center all floats" rule so they open under their button
hl.window_rule({ match = { class = "^(steam)$", float = true }, center = false })

hl.workspace_rule({ workspace = "name:steam", monitor = PRIMARY_MONITOR })
