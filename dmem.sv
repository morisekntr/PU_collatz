//61919734 Morise Kentaro
`include "pu.vh"
module dmem( // Data Memory
	input [`DMSB:0] ad,
	input [`DMWIDTH:0] wd,
	input we, dms,
	input logic [`CHM:0] ch,
	output logic [`DMWIDTH:0] rd,
	input clk, rst);
	logic [`DMWIDTH:0] col [`DMS:0];
	logic [`DMWIDTH:0] sum [`DMS:0];

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			col[0] <= 0;
			sum[0] <= 0;
		end
		else if(ch == 0) begin
			if(we) col[ad] <= wd;
		end
		else if(ch == 1) begin
			if(we) sum[ad] <= wd;
		end
	end
	
	always@* begin
		if(!dms) rd = 0;
		else if(ch == 0) rd = col[ad];
		else if(ch == 1) rd = sum[ad];
	end
endmodule
