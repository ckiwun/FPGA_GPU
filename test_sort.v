`timescale 1ns/10ps
`define CYCLE 10;
module test;

reg	clk;
reg	rst;
wire	[7:0]pixel_out;

sort	UDP(	.clk(clk),
				.rst(rst),
				.pixel_in0(8'd1),
				.pixel_in1(8'd9),
                .pixel_in2(8'd2),
                .pixel_in3(8'd7),
                .pixel_in4(8'd6),
                .pixel_in5(8'd4),
                .pixel_in6(8'd6),
                .pixel_in7(8'd2),
                .pixel_in8(8'd2),
                .pixel_out(pixel_out)
			);
initial begin
	clk = 0;
	rst = 0;
	#7 rst = 1;
	#23	$finish;
end

always #5 clk = ~clk;

initial begin
	$fsdbDumpfile("sort.fsdb");
	$fsdbDumpvars(0,test,"+mda");
end

endmodule