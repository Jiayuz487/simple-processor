# ECE 550 Project

Project Partners:
- Luis Morales (lam147)
- Jingyu Pan (jp502)
- Jiayu Zhang (jz370)

For this checkpoint our team implemented a MIPS processor that can respond to the following R-type and I-type instructions: add, addi, sub, and, or, sll, sra, sw, lw.

To enable our design, we created the following modules:
- **clock_divider.v:** a clock divider that was used to generate a processor_clock and imem_clock that are a _quarter_ of the skeleton.v input clock frequency; the unaltered input clock frequency was used for the dmem_clock and the regfile_clock to enable writeback to occur within a single cycle
- **imem.v:** ROM component generated using Quartus; initialized using *.mif files
- **dmem.v:** RAM component generated using Quartus; zero-initialized
- **sign_extender.v:** enables the handling of "immediate" instruction values by extending the number of bits from 17 to 32
- **opcode_decoder.v:** based on the opcode bits of an instruction, this module will generate various control bits that are used for subsequent stages of the processor (this includes values like the alu_opcode, write_enables for DMEM and regfile, etc.)
- **overflow_detector.v:** based on some of the previously calculated control signals, this module will calculate the corresponding value of $rstatus; per the provided ISA, this register should be set to **1** when there is an **add** instruction overflow, **2** when there is an **addi** instruction overflow, and **3** when there is a **sub** instruction overflow

Remaining Issues Description:
N/A (No known issues)
