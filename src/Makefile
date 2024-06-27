CFLAGS = -O0

all: hello_world

hello_world: hello_world.hex
	# riscv32-unknown-elf-objdump -d hello_world.elf > hello_world.s

hello_world.hex: hello_world.elf
	riscv32-unknown-elf-objcopy -O verilog $^ $@

hello_world.elf: hello_world/test.c linkerscript.ld
	riscv32-unknown-elf-gcc -march=rv32i \
		-T linkerscript.ld \
		-nostdlib \
		-o $@ \
		$<

clean:
	rm -f hello_world.elf hello_world.s hello_world.hex

.PHONY: all
.PHONY: clean
.PHONY: hello_world