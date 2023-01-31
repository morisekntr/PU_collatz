SRCS = pu.vh pu.sv alu.sv pc.sv imem.sv ra.sv dec.sv imx.sv sel.sv dmem.sv cdm.sv
TESTSRC = test.sv
ALLSRCS = pu.vh $(SRCS)
TESTSRCS = $(TESTSRC) $(SRCS)
VCDFILE = pu.vcd
YOSYSSCRIPT = pu.ys
OUTFILE = a.out
GATEFILE = gate.v
SYNTHFILE = synth.v
DOTFILE = show.dot
CELLFILE = ./osu018_stdcells/osu018_stdcells.v
all:		$(TESTSRCS) $(OUTFILE) $(VCDFILE)
		iverilog -g2012 $(TESTSRCS)
		vvp $(OUTFILE)
		open $(VCDFILE)
a.out:		$(TESTSRCS)
		iverilog -g2012 $(TESTSRCS)
pu.vcd:		$(OUTFILE)
		vvp $(OUTFILE)
open:		$(VCDFILE)
		open $(VCDFILE)
sim:		wave
wave:		$(VCDFILE)
		gtkwave $(VCDFILE)
gate.v:		$(TESTSRCS)
		yosys $(YOSYSSCRIPT)
synth:		$(TESTSRC) $(GATEFILE) $(CELLFILE) $(OUTFILE) $(VCDFILE)
		iverilog -gspecify -T typ $(TESTSRC) $(GATEFILE) $(CELLFILE)
		vvp $(OUTFILE)
		open $(VCDFILE)
yosys:		$(TESTSRCS)
		yosys $(YOSYSSCRIPT)
show:		$(DOTFILE)
		gvedit $(DOTFILE)
typsim:		$(GATEFILE)
		iverilog -gspecify -T typ $(TESTSRC) $(GATEFILE) $(CELLFILE)
minsim:		$(GATEFILE)
		iverilog -gspecify -T typ $(TESTSRC) $(GATEFILE) $(CELLFILE)
maxsim:		$(GATEFILE)
		iverilog -gspecify -T typ $(TESTSRC) $(GATEFILE) $(CELLFILE)
clean:
		-rm *.out *.vcd *.dot abc.history $(GATEFILE) $(SYNTHFILE)
#pu:
#		iverilog -g2012 $(SRCS)
alu:
		iverilog -g2012 alu.sv
pc:
		iverilog -g2012 pc.sv
imem:
		iverilog -g2012 imem.sv
ra:
		iverilog -g2012 ra.sv
dec:
		iverilog -g2012 dec.sv
imx:
		iverilog -g2012 imx.sv
sel:
		iverilog -g2012 sel.sv
dmem:
		iverilog -g2012 dmem.sv
cdm:
		iverilog -g2012 cdm.sv
