-- masterstack: master window on the LEFT, everything else stacked
-- VERTICALLY on the right (scroll-like column), like the screenshot.
-- Use as: general:layout = lua:masterstack  (or per-workspace layout)
--
-- Runtime commands (hyprctl layoutmsg):
--   layoutmsg master 0.6   -> set master width fraction (0.2..0.8)
--   layoutmsg grow         -> master wider by 0.05
--   layoutmsg shrink       -> master narrower by 0.05

local state = { master = 0.6 }

local function clamp(x, min, max)
    return math.max(min, math.min(max, x))
end

hl.layout.register("masterstack", {
    recalculate = function(ctx)
        local n = #ctx.targets
        if n == 0 then
            return
        end

        local area = ctx.area
        local x, y = area.x, area.y
        local w, h = area.w, area.h

        if n == 1 then
            ctx.targets[1]:place({ x = x, y = y, w = w, h = h })
            return
        end

        -- master: left, full height
        local mw = math.floor(w * state.master)
        ctx.targets[1]:place({ x = x, y = y, w = mw, h = h })

        -- stack: right side, n-1 equal vertical rows
        local stack_x = x + mw
        local stack_w = w - mw
        local rows = n - 1
        local row_h = math.floor(h / rows)
        for i = 2, n do
            local sy = y + (i - 2) * row_h
            local sh = row_h
            if i == n then
                sh = y + h - sy -- last window absorbs rounding remainder
            end
            ctx.targets[i]:place({ x = stack_x, y = sy, w = stack_w, h = sh })
        end
    end,

    layout_msg = function(ctx, msg)
        local command, arg = msg:match("^(%S+)%s*(.*)$")

        if command == "master" then
            state.master = clamp(tonumber(arg) or state.master, 0.2, 0.8)
        elseif command == "grow" then
            state.master = clamp(state.master + 0.05, 0.2, 0.8)
        elseif command == "shrink" then
            state.master = clamp(state.master - 0.05, 0.2, 0.8)
        else
            return "masterstack: expected master <0.2..0.8>, grow, or shrink"
        end

        return true
    end,
})
