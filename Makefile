VERLATOR=verilator -Wall --trace --cc

.PHONY: sim

sim: Vvtg

Vvtg:
	-${VERLATOR} rtl/vtg.sv --exe tb/vtg_tb.cpp
	make -j -C obj_dir -f Vvtg.mk