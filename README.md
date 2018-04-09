# Benchware

A utility for checking, testing and benchmarking a cluster.

## Running Commands 

### Run all tests for group

```
benchware --all --group=nodes
benchware -a -g nodes
```

### Run all tests for node

```
benchware --all --node=node001
benchware -a -n node001
```

###

### Output formats

Data will be output in YAML by default but can also be set as CSV

## List of Checks and Tests

- CPU
  - Number of Cores
  - Hyperthreading (enable/disable)
  - Model #
- Memory
  - Total
- Local Disks
  - Size
  - ISCSI BUS ID
  - Manufacturer
  - Model #
  - Serial #
  - Format Disk
  - Mount Path
  - Smartctl Self Check Result
- Network Disks
  - Mount Present?
- Network Interfaces
  - Type (Eth/IB/Bond/Bridge)
  - State (Up/Down)
  - Speed
  - Slaves (If Bridge/Bond)
  - MAC Address
  - PCI Slot / Adapter Location
- GPU
  - Type
  - Driver Version
- System Information
  - Service Tag
  - BIOS Version
- IPMI
  - SEL Errors
- Services
  - Date/Time
  - Queue System (SLURM)
  - User Management (IPA)
  - Node Monitoring (Ganglia/Nagios)
- Benchmarks
  - Memtester
  - HPL
  - DD Write Speed (for each disk)

## Example Command Module

```
module_name: name_of_module
repeat_list: "command to return newline separated list of items to run the commands on"
commands:
  command_name: "way of running test"
```

To use the entries in the `repeat_list` variable (`repeat_list` is optional) put all caps `ENTRY` in the command for it to be substituted at execution. 
