-- Helpers
-- hysteresis(off_below, on_above): returns an active() that latches on/off with hysteresis.
-- Off when pct drops below off_below; on when pct rises above on_above. Starts off.
function hysteresis(off_below, on_above)
    local on = false
    return function(current_pct, current_rf, direction)
        if on then
            if current_pct < off_below then on = false end
        else
            if current_pct > on_above then on = true end
        end
        return on
    end
end

-- Config
-- TARGETS: list of {side, color, active(current_pct, current_rf, direction)}.
-- direction is "filling", "draining", or "idle" based on RF change since the previous loop.
-- Multiple entries can share a side; their colors are OR'd into that side's bundled output.
TARGETS = {
    {
        side = "back",
        color = colors.white,
        active = function(current_pct, current_rf, direction)
            return false
        end,
    },
    -- {
    --     side = "left",
    --     color = colors.red,
    --     active = hysteresis(0.10, 0.90),
    -- },
}

MODEM_LOCATION = "right"
IDENTIFIER = "pri_to_aux"

SENDER_ID = "bank_primary"

-- Init
print("Starting... Hold Ctrl + T to terminate")

modem = rednet.open(MODEM_LOCATION)
current_pct = 0
current_rf = 0
prev_rf = 0

function loop()
    while true do
        print("Hold Ctrl + T to terminate.\n")

        local delta_rf = current_rf - prev_rf
        local direction
        if delta_rf > 0 then
            direction = "filling"
        elseif delta_rf < 0 then
            direction = "draining"
        else
            direction = "idle"
        end

        local side_output = {}
        local results = {}
        for i, t in ipairs(TARGETS) do
            local on = t.active(current_pct, current_rf, direction)
            results[i] = on
            local prev = side_output[t.side] or 0
            if on then
                side_output[t.side] = colors.combine(prev, t.color)
            else
                side_output[t.side] = prev
            end
        end

        for side, mask in pairs(side_output) do
            redstone.setBundledOutput(side, mask)
        end

        print("Current Pct: ", current_pct * 100)
        print("Current RF: ", current_rf)
        print("Direction: ", direction)
        for i, t in ipairs(TARGETS) do
            print(string.format("  %s/%d: %s", t.side, t.color, tostring(results[i])))
        end

        prev_rf = current_rf

        local _, message = rednet.receive()
        while message ~= nil do
            -- loop until msg queue is empty
            local parts = {}
            for part in string.gmatch(message, '([^,]+)') do
                table.insert(parts, part)
            end
            if parts[1] == SENDER_ID then
                local msg_type = parts[2]
                local msg_value = tonumber(parts[3])
                if msg_type == "pct" then
                    current_pct = msg_value
                elseif msg_type == "cur" then
                    current_rf = msg_value
                end
            end
            _, message = rednet.receive(1)
        end

        term.clear()
    end
end

loop()
