# Introduction  
RIDECORE (RIsc-v Dynamic Execution CORE) is an Out-of-Order processor written in Verilog HDL. RIDECORE implements RISC-V, an open-source ISA that was originally designed by researchers at UC Berkeley (<http://www.riscv.org>).

RIDECORE's microarchitecture is based on "Modern Processor Design: Fundamentals of Superscalar Processors" (<https://www.waveland.com/browse.php?t=624&r=d|259>). Thus, we recommend users to read this book and our document (doc/ridecore_document.pdf) before using RIDECORE.

Our FPGA prototyping efforts have so far resulted in a prototype for Xilinx VC707 board. This prototype can operate at a clock frequency of 50MHz (Vivado 2015.2 is used for synthesizing and implementing the design).

Some of the hardware modules in RIDECORE are based on vscale (<https://github.com/ucb-bar/vscale>).

# Toolchain Installation (Linux)  

* riscv-tools  
riscv-tools include a C/C++ cross compiler for RISC-V and an ISA simulator. Please refer to the following URL for the installation guide: <http://riscv.org/software-tools/>

* iverilog  
iverilog is an open-source verilog simulator. To install iverilog in Ubuntu, run the following command:  
\# apt-get install iverilog  

* memgen  
memgen is an application generating binary code for RIDECORE from ELF files. The source code of memgen can be found in toolchain/memgen-v0.9. Run the make command to compile it.

# Structure of this repository  
The structure of this repository is described in doc/struct_repository.pdf.

# How to use  

* Compiling applications and generating binary code  
Some sample applications for RIDECORE can be found in src/test/ridecore/app. For each application, you can generate the binary code (init.bin) from the C code and the startup code (in Assembly) by using the make command. To use this binary code in verilog simulations, run "make copy" to copy it to src/test/ridecore/bin.

* Simulating RIDECORE  
The simulation code of RIDECORE can be found in src/test/ridecore/sim.
You can generate an a.out executable file by running the make command.
Currently, there are three options:
  - "make last" (testbench_last.v is compiled): generates an a.out executable file for executing applications without outputting any information about the states of RIDECORE during the execution.
  - "make dbg" (testbench.v is compiled): generates an a.out executable file which reports the states of RIDECORE in every clock cycle while executing applications.
  - "make pred" (testbench_pred.v is compiled): generates an a.out executable file which reports the branch prediction information while executing applications.

