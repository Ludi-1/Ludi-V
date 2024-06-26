import cocotb
from cocotb.triggers import FallingEdge, Timer, Edge, RisingEdge
from cocotb.clock import Clock
from cocotb.types import LogicArray, Array, Range, Bit

class TB:
    def __init__(self, dut):
        self.dut = dut

    async def address(self):
        for i in range(0, 10):
            await Timer(10, units='ns')
            self.dut.address.value = i*4

@cocotb.test()
async def data_mem_test_1(dut):
    tb = TB(dut)
    await cocotb.start(tb.address())
    await Timer(10**3, units="ns")