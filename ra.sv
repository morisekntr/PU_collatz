//61919734 Morise Kentaro
`include "pu.vh"
module ra(
	input logic [`RASB:0] arad, brad,
	output [`DMWIDTH:0] a, b,
	input we,
	input logic [`RASB:0] wad,
	input [`DMWIDTH:0] wd,
	input clk, rst);
	logic [`DMWIDTH:0] rega [`RAS:0];
	always @(posedge clk or posedge rst)
		if(rst) begin
			rega[0] <= 0;
			rega[1] <= 0;
			rega[2] <= 0;
			rega[3] <= 0;
		end else begin
			if(we) rega[wad] <= wd;
		end
	assign a = rega[arad];
	assign b = rega[brad];
endmodule
