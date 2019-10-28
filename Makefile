VERLATOR=verilator -Wall -O3 --trace --MMD --cc -Irtl -Itb -f packages.f
VERILATOR_ROOT := /usr/share/verilator
VINCD := $(VERILATOR_ROOT)/include
GFXFLAGS:= `pkg-config gtkmm-3.0 --cflags`
GFXLIBS := `pkg-config gtkmm-3.0 --libs`
OBJDIR  := obj_dir
VOBJS   := $(OBJDIR)/verilated.o $(OBJDIR)/verilated_vcd_c.o
VINCS	:= -I $(VINCD) -I $(OBJDIR)
VGASIM  := tb/vgasim/vgasim.cpp tb/vgasim/image.cpp
CXXFLAGS := -O3 -march=native
DEPS := $(wildcard $(OBJDIR)/*.d)

.PHONY: all
all: Vvtg Vgame_state

$(OBJDIR)/%.o: $(VINCD)/%.cpp
	$(mk-objdir)
	$(CXX) $(CXXFLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/V%__ALL.a: rtl/%.sv
	-${VERLATOR} --top-module $(*F) $< 
	$(MAKE) -C obj_dir -f V$(*F).mk

$(OBJDIR)/V%__ALL.a: tb/%.sv
	-${VERLATOR} --top-module $(*F) $< 
	$(MAKE) -C obj_dir -f V$(*F).mk

BIN_Vvtg := $(OBJDIR)/Vvtg
.PHONY: Vvtg
Vvtg: $(BIN_Vvtg)
$(BIN_Vvtg): $(VOBJS) $(VGASIM) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a
	$(CXX) $(CXXFLAGS) $(GFXFLAGS) $(VINCS) $(VOBJS) $(GFXLIBS) $(VGASIM) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a -o $@

BIN_Vgame_state := $(OBJDIR)/Vgame_state
.PHONY: Vgame_state
Vgame_state: $(BIN_Vgame_state)
$(BIN_Vgame_state): $(VOBJS) tb/game_state_tb.cpp $(OBJDIR)/Vgame_state_tb__ALL.a
	$(CXX) $(CXXFLAGS) $(VINCS) $(VOBJS) tb/game_state_tb.cpp $(OBJDIR)/Vgame_state_tb__ALL.a -o $@

BIN_Vdrawing_test := $(OBJDIR)/Vdrawing_test
.PHONY: Vdrawing_test
Vdrawing_test: $(BIN_Vdrawing_test)
$(BIN_Vdrawing_test): $(VOBJS) $(VGASIM) tb/drawing_test.cpp $(OBJDIR)/Vdrawing_test__ALL.a
	$(CXX) $(CXXFLAGS) $(GFXFLAGS) $(VINCS) $(GFXLIBS) $(VOBJS) $(VGASIM) tb/drawing_test.cpp $(OBJDIR)/Vdrawing_test__ALL.a -o $@

define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef