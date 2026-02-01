-- Config
function active(current_pct, current_rf)
    -- Returns true if redstone should be active
    return false
end

TARGET_NAME_OR_LOCATION = "back"

MODEM_LOCATION = "right"
IDENTIFIER = "pri_to_aux"

SENDER_ID = "bank_primary"

-- Init
print("Starting... Hold Ctrl + T to terminate")

modem = rednet.open(MODEM_LOCATION)
function loop()
    while true do
        print("Hold Ctrl + T to terminate.\n")
        local current_pct = 0
        local current_rf = 0
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
        local rs_active = active(current_pct, current_rf)
        redstone.setOutput(TARGET_NAME_OR_LOCATION, rs_active)
        print("Current Pct: ", current_pct * 100)
        print("Current RF: ", current_rf)
        print("Redstone Active: ", rs_active)
        os.sleep(3)

        term.clear()
    end
end

loop()
