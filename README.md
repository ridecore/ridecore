# Introduction
RIDECORE (RIsc-v Dynamic Execution CORE) is an Out-of-Order RISC-V processor written in Verilog HDL.
This processor microarchitecture is based on "Modern Processor Design: Fundamentals of Superscalar Processors" (<https://www.waveland.com/browse.php?t=624&r=d|259>).
We recommend users to read this book and our document in </doc> before using RIDECORE.  
RIDECORE is synthesizable on Vivado (2015.2) and can run on FPGA (50MHz on a VC707).  
This processor is based on RISC-V ISA from UC Berkeley (<http://www.riscv.org>), 
and some of hardware module in RIDECORE is based on vscale (<https://github.com/ucb-bar/vscale>).  

# Install Toolchain (for Linux)

* riscv-tools  
riscv-tools includes C/C++ cross compiler for RISC-V and ISA simulator.  
You can install riscv-tools by reading this URL.
(<http://riscv.org/software-tools/>)

* iverilog  
iverilog is verilog simulator. You can install iverilog like this (In Ubuntu).  
\# apt-get install iverilog  

* memgen  
memgen is application that generates binary for RIDECORE from .elf file.  
This application is in toolchain/memgen-v0.9.  
You can get binary of memgen by using make command in the directory.  

# Structure of this repository
Read doc/struct_repository.pdf  

# How to use

* Compille Application and generates binary  
Sample application directories for RIDECORE are in src/test/ridecore/app.  
You can generate binary (init.bin) from C code and startup code by using make command.  
To use this binary in verilog simulation, copy init.bin to src/test/ridecore/bin by typing "make copy".  

* Simulate RIDECORE  
Verilog code for simulation is in src/test/ridecore/sim.  
There are some code for simulation. To simulate RIDECORE by iverilog, generate a.out by make command and run it.  
When you just want to execute an application, use "testbench_last.v" (make last).  
When you want to check the state of RIDECORE in every cycle, use "testbench.v" (make dbg).  
When you want to know the information of branch prediction, use "testbench_pred.v" (make pred).  

