#include <iostream>
#include "Vvtg.h"
#include "testb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

class TESTBENCH : public TESTB<Vvtg> {};

int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
    auto tb = new TESTBENCH;
    
    tb->opentrace("trace/vtg.vcd");

    tb->reset();
    while (!Verilated::gotFinish() && tb->m_tickcount < 1000000) {
        tb->tick();
    }
}