# mini-rv

A simple RV32I core, that is currently not pipelined and as a start only supports add(i) and some branch instructions to test early

## Compilation & Simulation

Compilation and Simulation was mainly done with iverilog & vvp.
All the testbenchens can be found in the sim directory with a `tb_` prefix

### Waveform Dump format

To reduce file size the waveform can be dumped in the .fst format by seting the extra argument (after setting the simulation file) `-fst`, 
which works well with gtkwave
