-- Config

BANK_NAME_OR_LOCATION = "tile_blockcapacitorbank_name_3"
BANK_TOTAL_CAPACITY_RF = 1275000000

MODEM_LOCATION = "right"
IDENTIFIER = "bank_primary"

-- Init
print("Starting... Hold Ctrl + T to terminate")

cell = peripheral.wrap(BANK_NAME_OR_LOCATION)
modem = rednet.open(MODEM_LOCATION)

while true do
    print("Hold Ctrl + T to terminate.\n")
    local cell_max_energy = cell.getMaxEnergyStored()
    local cell_cur_energy = cell.getEnergyStored()

    local energy_pct = cell_cur_energy / cell_max_energy
    local bank_cur_energy = energy_pct * BANK_TOTAL_CAPACITY_RF
    print("Max Capacity (RF): ", BANK_TOTAL_CAPACITY_RF)
    print("Current Energy (RF): ", bank_cur_energy)
    print("Pct: ", energy_pct * 100)

    rednet.broadcast(string.format("%s,max,%.2f", IDENTIFIER, BANK_TOTAL_CAPACITY_RF))
    rednet.broadcast(string.format("%s,cur,%.2f", IDENTIFIER, bank_cur_energy))
    rednet.broadcast(string.format("%s,pct,%.4f", IDENTIFIER, energy_pct))
    os.sleep(3)

    term.clear()
end

