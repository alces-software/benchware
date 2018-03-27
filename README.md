# Benchware

A utility for checking, testing and benchmarking a cluster.

## Running Commands 

### Run all tests for group

benchware --all --group=nodes
benchware -a -g nodes

### Run all tests for node

benchware --all --node=node001
benchware -a -n node001

## List of Checks and Tests

- CPU
  - # Cores
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
- GPU
  - Type
  - Driver Version
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

