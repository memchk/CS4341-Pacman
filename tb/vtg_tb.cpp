#include <iostream>
#include "Vvtg.h"
#include "testb.h"
#include "vgasim/vgasim.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

class TESTBENCH : public TESTB<Vvtg> {
public:
    VGAWIN m_vga;

public:

    TESTBENCH(int h, int v): m_vga(h, v) {
        Glib::signal_idle().connect(sigc::mem_fun((*this),&TESTBENCH::on_tick));
    }

    bool on_tick() {
        for (size_t i = 0; i < 1000; i++)
        {
            tick();
        }
        return true;
    }

    void tick(void) override {
        m_vga((m_core->o_vsync)?1:0, (m_core->o_hsync)?1:0,
			255,
			0,
			0);
		TESTB<Vvtg>::tick();
	}
};

int main(int argc, char** argv) {
    Gtk::Main	main_instance(argc, argv);
	Verilated::commandArgs(argc, argv);

    auto tb = new TESTBENCH(800, 600);
    Gtk::Main::run(tb->m_vga);
}