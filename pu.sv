//61919734 Morise Kentaro
`include "pu.vh"
module pu( // Processing Unit
	output we,
	output [`DMWIDTH:0] rwd,
	input clk, rst);
	logic [`DMWIDTH:0] a2sel, b2alu, a2alu, b2imx, loop, dmrd;
	logic [`HALFWIDTH:0] iv;
	logic [`RASB:0] arad, brad, wad;
	logic [`ALUOPS:0] op;
	logic [`PCS:0] pca;
	logic [`CMDS:0] o;
	logic [`IMXOPS:0] liop;
	logic [`CHM:0] ch, dmch;
	ra ra(arad, brad, a2sel, b2imx, we, wad, rwd, clk, rst);
	sel asel(a2sel, {{(`DMWIDTH-`PCS){1'b0}},pca}, pcs, a2alu);
	imx imx(b2imx, iv, liop, b2alu);
	alu alu(a2alu, b2alu, op, sr, loop, ze, ca, sg, od, clk, rst);
	pc pc(h, pca, pcwe, rwd[`PCS:0], clk, rst);
	imem imem(pca, o);
	dec dec(o, h, we, wad, op, brad, arad, liop, iv,
		pcwe, dmwe, dms, pcs, sr, ch, chs, ze, ca, sg, od);
	cdm cdm(ch, chs, dmch, clk, rst);
	dmem dmem(loop[`DMSB:0], b2imx, dmwe, dms, dmch, dmrd, clk, rst);
	sel dsel(loop, dmrd, dms, rwd);
endmodule

