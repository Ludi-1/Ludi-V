# Ludi-V
A RV32I processor

## Functionalities


## Setup guide
Download the [riscv32-unknown-elf-gcc toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
```
./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32
make

echo 'export PATH="$PATH:/opt/riscv/bin"' &>> ~/.bashrc
```

```
vivado -mode tcl -source scripts/project.tcl
```
