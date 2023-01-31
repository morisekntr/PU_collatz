//61919734 Morise Kentaro
`include "pu.vh"
module alu( // ALU
	input [`DMWIDTH:0] a, b,
	input [`ALUOPS:0] op,
	input sr,
	output [`DMWIDTH:0] r,
	output logic ze, ca, sg, od,
	input clk, rst);
	logic [`DMWIDTH+1:0] rr;
	always_comb begin
		case(op)
		// synopsys full_case parallel_case
		`ADD: rr = a+b;
		`SUB: rr = a-b;
		`ASR: rr = a>>>b; // Arithmetic Shift Right
		`RSR: rr = a>>b; // Rotate Shift Right
		`RSL: rr = a<<b; // Rotate Shift Left
		`BST: rr = a|(1<<b); // Bit Set
		`BRT: rr = a&(~(1<<b)); // Bit Reset
		`BTS: rr = {8{a[b]}}; // Bit Test
		`AND: rr = a&b;
		`OR:  rr = a|b;
		`NAD: rr = ~(a&b);
		`XOR: rr = a^b;
		`MUL: rr = a*b; // no carry
		`EXT: rr = 0; // for future reserved
		`THA: rr = a;
		`THB: rr = b;
		endcase
	end
	assign r = rr[`DMWIDTH:0];
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			ze <= `NEGATE;
			ca <= `NEGATE;
			sg <= `NEGATE;
			od <= `NEGATE;
		end else if(!sr) begin
			if(r == 0) ze <= `ASSERT;
			else ze <= `NEGATE;
			if(r[`DMWIDTH] == 1'b1) sg <= `ASSERT;
			else sg <= `NEGATE;
			if(rr[`DMWIDTH+1] == 1'b1) ca <= `ASSERT;
			else ca <= `NEGATE;
			if(r[0] == 1'b1) od <= `ASSERT;
			else od <= `NEGATE;
		end else begin
			if(r[0] == 1'b1) ze <= `ASSERT;
			else ze <= `NEGATE;
			if(r[1] == 1'b1) ca <= `ASSERT;
			else ca <= `NEGATE;
			if(r[2] == 1'b1) sg <= `ASSERT;
			else sg <= `NEGATE;
			if(r[3] == 1'b1) od <= `ASSERT;
			else od <= `NEGATE;
		end
	end
endmodule
