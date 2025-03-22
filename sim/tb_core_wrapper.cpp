#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vcore_wrapper.h"

#define MAX_SIM_TIME 60
vluint64_t sim_time = 0;

int main(int argc, char** argv, char** env) {
  Vcore_wrapper *dut = new Vcore_wrapper;
  Verilated::traceEverOn(true);
  VerilatedVcdC *m_trace = new VerilatedVcdC;
  dut->trace(m_trace, 10);
  m_trace->open("waveform.vcd");
  dut->rstn = 1;

  dut->awready = 1;
  dut->wready = 1;
  dut->arready = 0;
  dut->rdata = 0;
  dut->rvalid = 0;
  

  while (sim_time < MAX_SIM_TIME) {
    dut->clk ^= 1;
    dut->eval();
    if (dut->awvalid && dut->awready) {
      std::cout << "[AXI MONITOR] Write Addr: " << std::hex << dut->awaddr << std::endl;
    }
    if (dut->wvalid && dut->wready) {
      std::cout << "[AXI MONITOR] Write Data: " << std::hex << dut->wdata << std::endl;
    }
    if (dut->bvalid && dut->bready) {
      std::cout << "[AXI MONITOR] Write Response Received" << std::endl;
    }
    if (dut->arvalid && dut->arready) {
      std::cout << "[AXI MONITOR] Read Addr: " << std::hex << dut->araddr << std::endl;
    }
    if (dut->rvalid && dut->rready) {
      std::cout << "[AXI MONITOR] Read Data: " << std::hex << dut->rdata << std::endl;
    }
    m_trace->dump(sim_time);
    sim_time++;
  }

  m_trace->close();
  delete dut;
  exit(EXIT_SUCCESS);
}
