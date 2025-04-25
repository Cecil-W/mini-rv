# mini-rv32

A simple single-cycle RV32I core, that is currently not pipelined or synthesizable

## Compilation & Simulation

Compilation and Simulation was mainly done with iverilog & vvp.
All the testbenchens can be found in the sim directory with a `tb_` prefix.
The file `core.cf` is a command file for iverilog with the correct compile order to compile the core. To compile a specific testbench just specify `-c core.cf testbench.sv`.

### Waveform Dump format

To reduce file size the waveform can be dumped in the .fst format by seting the extra argument (after setting the simulation file) `-fst`, 
which works well with gtkwave
