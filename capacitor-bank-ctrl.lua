-- Config
function active(sender_id, current_pct, current_rf)
    -- Returns true if redstone should be active
    return false
end

TARGET_NAME_OR_LOCATION = "back"

MODEM_LOCATION = "right"
IDENTIFIER = "pri_to_aux"

-- Init
print("Starting... Hold Ctrl + T to terminate")

modem = rednet.open(MODEM_LOCATION)
function loop()
    while true do
        print("Hold Ctrl + T to terminate.\n")
        local _, message = rednet.receive()
        if message == nil then
            return
        end
        print("Received message: ", message)
        os.sleep(3)

        term.clear()
    end
end

loop()
