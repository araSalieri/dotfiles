-- noctalia garnet: secondary gold #c8962a for the special workspace, terminal blue #4a7fb5 for steam
hl.window_rule({ match = { workspace = "special:ara" }, border_color = { colors = { "rgba(200, 150, 42, 1)" } } })

hl.window_rule({ match = { class = "^(steam)$" }, workspace = "name:steam", border_color = { colors = { "rgba(74, 127, 181, 1)" } } })

-- Steam dropdown menus are floating windows; undo the stock "center all floats" rule so they open under their button
hl.window_rule({ match = { class = "^(steam)$", float = true }, center = false })

hl.workspace_rule({ workspace = "name:steam", monitor = PRIMARY_MONITOR })
