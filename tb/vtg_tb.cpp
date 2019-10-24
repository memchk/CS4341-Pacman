#include <iostream>
#include "Vvtg.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    auto top = new Vvtg;

    top->trace(m_trace, 99);
    m_trace->open("trace/vtg.vcd");

    unsigned long m_tickcount = 0;

    while (!Verilated::gotFinish() && m_tickcount < 1000000) { 
        m_tickcount++;

        top->i_clk = 0;
        top->eval();
        m_trace->dump(10*m_tickcount-2);

        top->i_clk = 1;
        top->eval();
        m_trace->dump(10*m_tickcount);

        top->i_clk = 0;
        top->eval();
        m_trace->dump(10*m_tickcount+5);
    }
    m_trace->flush();
    m_trace->close();
    delete top;
    exit(0);
}