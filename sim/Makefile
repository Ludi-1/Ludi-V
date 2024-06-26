# Makefile for rtl/axi_lite_impl

# defaults
SIM = icarus
TOPLEVEL_LANG = verilog
PWD=$(shell pwd)

$(shell mkdir -p vcd)

VERILOG_SOURCES += $(PWD)/../rtl/rv32i_sc/*

COMP ?= rv32i_sc

# SIM_ARGS+= --wave=wave/$(TOPLEVEL)_tb.ghw

ifeq ($(COMP),rv32i_sc)
    TOPLEVEL = rv32i_sc
    MODULE = test_rv32i_sc
else ifeq ($(COMP), instr_mem)
    TOPLEVEL = instruction_memory
    MODULE = test_instr_mem
else
    $(error Given TOPLEVEL '$(TOPLEVEL)' not supported)
endif

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim