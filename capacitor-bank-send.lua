-- Config

BANK_NAME_OR_LOCATION = "tile_blockcapacitorbank_name_1"
BANK_TOTAL_CAPACITY_RF = 1275000000

MODEM_LOCATION = "right"
CHAN = 100

-- Init
print("Starting... Hold Ctrl + T to terminate")

cell = peripheral.wrap(BANK_NAME_OR_LOCATION)
modem = peripheral.wrap(MODEM_LOCATION)

while true do
    local cell_max_energy = cell.getMaxEnergyStored()
    local cell_cur_energy = cell.getEnergyStored()

    local energy_pct = cell_cur_energy / cell_max_energy
    local bank_cur_energy = energy_pct * BANK_TOTAL_CAPACITY_RF
    print("Max Capacity (RF): ", BANK_TOTAL_CAPACITY_RF)
    print("Current Energy (RF): ", bank_cur_energy)
    print("Pct: ", energy_pct * 100)

    modem.transmit(CHAN, CHAN + 1, string.format("max, %.2f", BANK_TOTAL_CAPACITY_RF))
    modem.transmit(CHAN, CHAN + 1, string.format("cur, %.2f", bank_cur_energy))
    modem.transmit(CHAN, CHAN + 1, string.format("pct, %.4f", energy_pct))
    os.sleep(3)

    term.clear()
    print("Hold Ctrl + T to terminate.\n")
end

