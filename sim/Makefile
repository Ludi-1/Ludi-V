# Makefile for rtl/axi_lite_impl

# defaults
SIM = verilator
TOPLEVEL_LANG = verilog
PWD=$(shell pwd)
WAVES=1
EXTRA_ARGS += --trace-fst --trace-structs
EXTRA_ARGS += --trace --trace-structs

$(shell mkdir -p vcd)

TOPLEVEL ?= top

ifeq ($(TOPLEVEL),instr_mem)
    VERILOG_SOURCES += $(PWD)/../rtl/core/instr_mem.sv
    MODULE = test_instr_mem
else ifeq ($(TOPLEVEL),stage_fetch)
    VERILOG_SOURCES += $(PWD)/../rtl/core/instr_mem.sv
    VERILOG_SOURCES += $(PWD)/../rtl/core/stage_fetch.sv
    MODULE = test_stage_fetch
else ifeq ($(TOPLEVEL),stage_decode)
    VERILOG_SOURCES += $(PWD)/../rtl/core/stage_decode.sv
    MODULE = test_stage_decode
else ifeq ($(TOPLEVEL),top)
    VERILOG_SOURCES += $(PWD)/../rtl/top.sv
    VERILOG_SOURCES += $(PWD)/../rtl/core/*
    MODULE = test_top
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim