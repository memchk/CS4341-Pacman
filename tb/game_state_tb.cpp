#include "testb.h"
#include "Vgame_state_tb.h"
#include "verilated.h"

class TESTBENCH : public TESTB<Vgame_state_tb> {};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    TESTBENCH tb;
    tb.opentrace("trace/game_state.vcd");
    tb.reset();
    while(!Verilated::gotFinish() && tb.m_tickcount < 1000000) {
        tb.tick();
    }
    return 0;
}