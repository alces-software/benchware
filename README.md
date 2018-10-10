# Benchware

A utility for checking, testing and benchmarking a cluster.

## Installing

- Clone benchware

```
git clone https://github.com/alces-software/benchware /opt/benchware
```

- Install gem dependencies

```
gem install cli-ui --version='1.1.1'
gem install erubis
```

## Running Commands 

### Run all tests for a genders group

```
cd /opt/benchware && ./benchware.rb --all --nodes "$(nodeattr -s mygendersgroup)"
cd /opt/benchware && ./benchware.rb -a -n "$(nodeattr -s mygendersgroup)"
```

### Run inventory checks for some nodes

```
cd /opt/benchware && ./benchware.rb --profile inv --nodes "node001 node002 thisnode01"
cd /opt/benchware && ./benchware.rb -p inv -n "node001 node002 thisnode01"
```

### Output formats

The output format refers to how the file written by benchware will format the data. Without the `-q` option benchware will do a page-based yaml output which can be scrolled through.

Data will be output in yamdown by default, a hybrid of yaml and markdown for use with Flight Center web services. Data can also be output in plain yaml.

## List of Checks and Tests

- CPU
  - Number of CPUs
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
  - User Management (IPA) - NOT YET IMPLEMENTED
  - Node Monitoring (Ganglia)
- Benchmarks
  - Memtester
  - HPL
  - DD Write Speed (for each disk)

## Example Command Module

```
module_name: name_of_module
dependencies: "package_name another_package"
repeat_list: "command to return newline separated list of items to run the commands on"
commands:
  command_name: "way of running test"
scripts:
  script_name: "path/to/script"
```

- The list of packages in `dependencies` will be installed with yum prior to any of the commands or scripts within it running
- To use the entries in the `repeat_list` variable (`repeat_list` is optional) put all caps `ENTRY` in the command for it to be substituted at execution. For scripts ENTRY will be the first argument given to the script upon execution.
- Scripts allow for larger commands (which require a bit more than a one-liner to get suitable output) to be specified with a relative path to the _benchware installation directory_, this script is then copied across to the client node temporarily to be executed.
