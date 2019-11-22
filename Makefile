VERLATOR=verilator -O3 --trace --MMD --cc -y rtl -y tb -f packages.f
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

ALLSV := $(wildcard rtl/*.sv) $(wildcard tb/*.sv)

.PHONY: all
all: Vdrawing_test Vgame_state Vvideo_arbiter

$(OBJDIR)/%.o: $(VINCD)/%.cpp
	$(mk-objdir)
	$(CXX) $(CXXFLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/V%__ALL.a: tb/%.sv $(ALLSV)
	${VERLATOR} --top-module $(*F) $< 
	$(MAKE) -C obj_dir -f V$(*F).mk

$(OBJDIR)/V%__ALL.a: rtl/%.sv $(ALLSV)
	${VERLATOR} --top-module $(*F) $< 
	$(MAKE) -C obj_dir -f V$(*F).mk

BIN_Vvtg := $(OBJDIR)/Vvtg
.PHONY: Vvtg
Vvtg: $(BIN_Vvtg)
$(BIN_Vvtg): $(VOBJS) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a
	$(CXX) $(CXXFLAGS) $(VINCS) $(VOBJS) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a -o $@

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


BIN_Vvideo_arbiter := $(OBJDIR)/Vvideo_arbiter
.PHONY: Vvideo_arbiter
Vvideo_arbiter: $(BIN_Vvideo_arbiter)
$(BIN_Vvideo_arbiter): $(VOBJS) tb/video_arbiter_tb.cpp $(OBJDIR)/Vvideo_arbiter__ALL.a
	$(CXX) $(CXXFLAGS) $(VINCS) $(VOBJS) tb/video_arbiter_tb.cpp $(OBJDIR)/Vvideo_arbiter__ALL.a -o $@

define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef

DEPS := $(wildcard $(OBJDIR)/*.d)
ifneq ($(DEPS),)
include $(DEPS)
endif