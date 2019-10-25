#include "testb.h"
#include "Vgame_state.h"
#include "verilated.h"

class TESTBENCH : public TESTB<Vgame_state> {};

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    TESTBENCH tb;
    tb.opentrace("trace/game_state.vcd");
    tb.reset();
    while(!Verilated::gotFinish()) {
        tb.m_core->i_en = 1;
        for (size_t i = 0; i < 16; i++)
        {
            tb.m_core->i_joystick = 0b0100;
            tb.tick();
        }
        tb.m_core->i_en = 0;
        tb.tick();
    }
    return 0;
}