-- Config

REFINERY_CHAN = 10
MODEM_LOCATION = "right"
REFINERY_LOCATION = "top"

-- Init
modem = peripheral.wrap(MODEM_LOCATION)
modem.open(REFINERY_CHAN)

prev_message = false

print("Starting... Hold Ctrl + T to terminate")

-- Loop
while true do
  local _, _, _, _, message, _ = os.pullEvent("modem_message")
  if message ~= prev_message then
    print("Changing state from ", prev_message, " to ", message)
    redstone.setOutput(REFINERY_LOCATION, message)
    prev_message = message
  end

  os.sleep(1)

  term.clear()
  print("Hold Ctrl + T to terminate.\n")
end
