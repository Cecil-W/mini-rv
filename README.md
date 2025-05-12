# mini-rv32

A simple in-order RV32I core, that is pipelined into 4 stages (fetch, decode, execute, writeback).
Data Hazards are avoided with forwarding, and control hazards are handled by inserting a NOP when a branch gets decoded.

## Compilation & Simulation

Compilation and Simulation was mainly done with iverilog & vvp.
All the testbenchens can be found in the sim directory with a `tb_` prefix.
The file `core.cf` is a command file for iverilog with the correct compile order to compile the core. To compile a specific testbench just specify `-c core.cf testbench.sv`.

### Waveform Dump format

To reduce file size the waveform can be dumped in the .fst format by seting the extra argument (after setting the simulation file) `-fst`, which works well with gtkwave
