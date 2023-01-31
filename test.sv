//61919734 Morise Kentaro
`timescale 1ns/10ps
`include "pu.vh"
module test;
	reg clk, rst;
	wire we;
	wire [`DMWIDTH:0] wd;
	pu pu(we, wd, clk, rst);
	always #5 clk =~ clk;
initial begin
$dumpfile("pu.vcd");
$dumpvars(0, pu);
rst = 1;
clk = 1;
#20
rst = 0;
#50000
$finish;
end
endmodule
