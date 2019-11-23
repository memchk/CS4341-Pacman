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
    int m_joystick;
public:

    TESTBENCH(int h, int v): m_vga(h, v) {
        m_move_dir = true;
        m_vga.signal_key_press_event().connect(sigc::mem_fun((*this), &TESTBENCH::on_keypress), false);
        Glib::signal_idle().connect(sigc::mem_fun((*this),&TESTBENCH::on_tick));
    }

    bool on_tick() {
        for (size_t i = 0; i < 1000; i++)
        {
            tick();
        }
        return true;
    }

    bool on_keypress(GdkEventKey *event) {
        switch (event->keyval) {
            case GDK_KEY_a:
                m_joystick = 0b0001;
                break;
            case GDK_KEY_s:
                m_joystick = 0b0010;
                break;
            case GDK_KEY_d:
                m_joystick = 0b0100;
                break;
            case GDK_KEY_w:
                m_joystick = 0b1000;
                break;
        }

        return true;
    }

    void tick(void) override {
        m_vga((m_core->o_vsync)?1:0, (m_core->o_hsync)?1:0,
			m_core->o_r,
			m_core->o_g,
			m_core->o_b);
        
        m_core->i_joystick = m_joystick;

		TESTB<Vdrawing_test>::tick();
	}
};

int main(int argc, char** argv) {
    Gtk::Main	main_instance(argc, argv);
	Verilated::commandArgs(argc, argv);

    auto tb = new TESTBENCH(800, 600);
    // tb->opentrace("trace/drawing_test.vcd");
    tb->reset();
    Gtk::Main::run(tb->m_vga);
}