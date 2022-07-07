# MicroProcessor Design

## A VHDL Description of a Micro-Processor that performs the Instruction Set Architecture (ISA) of the Advanced RISC Machine (ARM)

This project has been written completly in VHDL and can be simulated by any simulator such as Aldec Rivera or GHDL.

---

### Simulate online with Aldec Rivera

To simulate on Aldec Rivera for free, please visit [The Project on eda playground](https://www.edaplayground.com/x/jnzW) and enable

- [x] Open EPWave after run

Then, click on `Run`

---

### Simulate offline with GHDL

Install the opensource vhdl simulator `GHDL` and `GTKWAVE`. Following ahead is the code for running the project on Windows.

#### Build

Migrate to the current directory (the one that contains README.md) and execute

    ghdl -a src\MyTypes.vhd
    ghdl -a src\testbench.vhd

to generate a `*.cf` file in the present working directory.

#### Run

Execute

    ghdl -r testbench -vcd=design.vcd

to create a design.vcd file in the present working directory.

#### View the Wave

Execute

    gtkwave design.vcd

to open up the generated wave and view the required signals.
