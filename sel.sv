//61919734 Morise Kentaro
`include "pu.vh"
module sel(
	input [`DMWIDTH:0] a, b,
	input s,
	output logic [`DMWIDTH:0] o);
	always@* begin
		if(s) o = b;
		else o = a;
	end
endmodule
