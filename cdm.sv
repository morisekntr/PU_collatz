//61919734 Morise Kentaro
`include "pu.vh"
module cdm( 
	input [`CHM:0] ch,
	input chs,
	output logic [`CHM:0] dmch,
	input clk, rst);

	logic [`CHM:0] state;
	
	always @(posedge clk or posedge rst) begin
        if(rst) state <= 0;
        else state <= dmch;
    end

    always@* begin
		dmch = state;
		if(chs) dmch = ch;
	end
endmodule
