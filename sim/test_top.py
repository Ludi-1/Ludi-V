import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray, Array, Range, Bit

@cocotb.test()
async def stage_fetch_test(dut):
    clock = Clock(dut.clk, 5, units="ns")  # Create a 4ns clock period
    cocotb.start_soon(clock.start())  # Start the clock

    dut.rstn.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    dut.rstn.value = 1

    for _ in range(256):
        await RisingEdge(dut.clk)
    