#include "testb.h"
#include "Vgame_state_tb.h"
#include "verilated.h"

class TESTBENCH : public TESTB<Vgame_state_tb> {};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    TESTBENCH tb;
    tb.opentrace("trace/game_state.vcd");
    tb.reset();
    tb.m_core->i_joystick = 1;
    while(!Verilated::gotFinish() && tb.m_tickcount < 1000) {
        tb.m_core->i_en = 1;
        TBADVANCE(20);
        tb.m_core->i_en = 0;
        TBADVANCE(20);
    }
    return 0;
}