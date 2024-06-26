from riscv_assembler.convert import *

cnv = AssemblyConverter(nibble_mode = True)
result = cnv.convert("./src/add.s")
for instr in result:
    print(instr)