//61919734 Morise Kentaro
`include "pu.vh"
module imx( // Immediate Value Mixer
	input [`DMWIDTH:0] i,
	input [`HALFWIDTH:0] iv,
	input [`IMXS:0] op,
	output logic [`DMWIDTH:0] o);
	always@* begin
		casex(op)
		// synopsys full_case parallel_case
		`LIL:
			o = {i[`DMWIDTH:`HALFWIDTH+1],iv};
		`LIH:
			o = {i[`DMWIDTH:`WIDTH+1],iv,i[`HALFWIDTH:0]};
		`IMM:
			o = {{(`DMWIDTH - `HALFWIDTH){1'b0}},iv};
		`THU:
			o = i;
		endcase
	end
endmodule
