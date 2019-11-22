#include "testb.h"
#include "Vvideo_arbiter.h"
#include "verilated.h"

class TESTBENCH : public TESTB<Vvideo_arbiter> {};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    TESTBENCH tb;
    tb.opentrace("trace/video_arbiter.vcd");
    tb.reset();
    tb.tick();
    tb.m_core->i_vsync = 1;
    tb.m_core->i_hsync = 1;
    tb.m_core->i_vport[0] = 0xDEADBE;
    tb.m_core->i_vport[1] = 0xCAFEBA;
    
    tb.m_core->i_req = 0b01;
    TBADVANCE(10);
    tb.m_core->i_req = 0b10;
    TBADVANCE(10);
    return 0;
}