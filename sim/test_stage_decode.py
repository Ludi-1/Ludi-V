import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge
import random

@cocotb.test()
async def stage_decode_test(dut):
    clock = Clock(dut.clk, 5, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    dut.rst.value = 1
    dut.instr.value = 0
    dut.rst.value = 0
    dut.fetch_instr_addr.value = 0
    await RisingEdge(dut.clk)
    dut.rst.value = 0
    await RisingEdge(dut.clk)

    for _ in range(100):
        await RisingEdge(dut.clk)
    