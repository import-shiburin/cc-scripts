-- Config
-- TARGETS: list of {side, color, active(current_pct, current_rf)}.
-- Multiple entries can share a side; their colors are OR'd into that side's bundled output.
TARGETS = {
    {
        side = "back",
        color = colors.white,
        active = function(current_pct, current_rf)
            return false
        end,
    },
    -- {
    --     side = "left",
    --     color = colors.red,
    --     active = function(current_pct, current_rf)
    --         return current_pct < 0.25
    --     end,
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

function loop()
    while true do
        print("Hold Ctrl + T to terminate.\n")

        local side_output = {}
        local results = {}
        for i, t in ipairs(TARGETS) do
            local on = t.active(current_pct, current_rf)
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
        for i, t in ipairs(TARGETS) do
            print(string.format("  %s/%d: %s", t.side, t.color, tostring(results[i])))
        end

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
