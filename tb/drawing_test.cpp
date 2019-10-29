#include <iostream>
#include "Vdrawing_test.h"
#include "testb.h"
#include "vgasim/vgasim.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

class TESTBENCH : public TESTB<Vdrawing_test> {
public:
    VGAWIN m_vga;
private:
    bool m_move_dir;
public:

    TESTBENCH(int h, int v): m_vga(h, v) {
        m_move_dir = true;
        Glib::signal_idle().connect(sigc::mem_fun((*this),&TESTBENCH::on_tick));
    }

    bool on_tick() {
        for (size_t i = 0; i < 5; i++)
        {
            tick();
        }
        return true;
    }

    void tick(void) override {
        m_vga((m_core->o_vsync)?1:0, (m_core->o_hsync)?1:0,
			m_core->o_r,
			m_core->o_g,
			m_core->o_b);

        if(m_tickcount % 1000000 < 500000) {
            m_core->i_joystick = 0b0010;
        } else {
            m_core->i_joystick = 0b0100;
        }

		TESTB<Vdrawing_test>::tick();
	}
};

int main(int argc, char** argv) {
    Gtk::Main	main_instance(argc, argv);
	Verilated::commandArgs(argc, argv);

    auto tb = new TESTBENCH(800, 600);
    //tb->opentrace("trace/drawing_test.vcd");
    tb->reset();
    Gtk::Main::run(tb->m_vga);
}