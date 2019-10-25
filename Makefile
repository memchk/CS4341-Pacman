VERLATOR=verilator -Wall --trace --cc
VERILATOR_ROOT := /usr/share/verilator
VINCD := $(VERILATOR_ROOT)/include
GFXFLAGS:= `pkg-config gtkmm-3.0 --cflags`
GFXLIBS := `pkg-config gtkmm-3.0 --libs`
OBJDIR  := obj_dir
VOBJS   := $(OBJDIR)/verilated.o $(OBJDIR)/verilated_vcd_c.o
VINCS	:= -I $(VINCD) -I $(OBJDIR)
VGASIM  := tb/vgasim/vgasim.cpp tb/vgasim/image.cpp

CXXFLAGS := -O3 -march=native

.PHONY: all
all: Vvtg Vgame_state

$(OBJDIR)/%.o: $(VINCD)/%.cpp
	$(mk-objdir)
	$(CXX) $(CXXFLAGS) $(INCS) -c $< -o $@

$(OBJDIR)/V%__ALL.a: rtl/%.sv
	-${VERLATOR} $< 
	$(MAKE) -C obj_dir -f V$(*F).mk


BIN_Vvtg := $(OBJDIR)/Vvtg
.PHONY: Vvtg
Vvtg: $(BIN_Vvtg)
$(BIN_Vvtg): $(VOBJS) $(VGASIM) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a
	$(CXX) $(CXXFLAGS) $(GFXFLAGS) $(VINCS) $(VOBJS) $(GFXLIBS) $(VGASIM) tb/vtg_tb.cpp $(OBJDIR)/Vvtg__ALL.a -o $@

BIN_Vgame_state := $(OBJDIR)/Vgame_state
.PHONY: Vgame_state
Vgame_state: $(BIN_Vgame_state)
$(BIN_Vgame_state): $(VOBJS) $(VGASIM) tb/game_state_tb.cpp $(OBJDIR)/Vgame_state__ALL.a
	$(CXX) $(CXXFLAGS) $(VINCS) $(VOBJS) tb/game_state_tb.cpp $(OBJDIR)/Vgame_state__ALL.a -o $@

define	mk-objdir
	@bash -c "if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi"
endef