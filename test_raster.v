`timescale 1ns/10ps
`define CYCLE 10
`define	PCIE_WRITE_TIME 200
`define TOO_LONG 1000
`define	SRAM_SIZE	640*480*4

`include "pseudo_proc.v"
module test;

reg		clk;
reg		rst;
wire	udp_proc_ready;
reg		udp_triangle_valid;
reg		[255:0]udp_triangle_data;
wire	[20:1]udp_sram_addr;
wire   	[15:0]udp_sram_data;
wire    udp_sram_we_n;
wire    udp_sram_oe_n;
wire	udp_proc_finish;

reg		[7:0]sram[`SRAM_SIZE-1:0];
integer	i;
integer	test_frame;


pseudo_proc	UDP(	.clk(clk),
					.rst(rst),
					.o_proc_ready(udp_proc_ready),
					.i_triangle_valid(udp_triangle_valid),
					.i_triangle_data(udp_triangle_data),
					.o_sram_addr(udp_sram_addr),
					.io_sram_data(udp_sram_data),
					.o_sram_we_n(udp_sram_we_n),
					.o_sram_oe_n(udp_sram_oe_n),
					.o_proc_finish(udp_proc_finish)
					);
initial begin
	clk = 0;
	rst = 0;
	#(`CYCLE*0.7) rst = 1;
	#(`TOO_LONG)	$finish;
end

always begin #(`CYCLE*0.5) clk = ~clk; end

initial begin
	$fsdbDumpfile("raster.fsdb");
	$fsdbDumpvars();
end

initial begin
	udp_triangle_valid = 0;
	udp_triangle_data = 0;
	#(`PCIE_WRITE_TIME)
	wait(udp_proc_ready)
	#(`CYCLE*3)
	udp_triangle_valid = 1;
	udp_triangle_data = 256'b0000000000000000_00000000_11000001_11000001_11000001_1011111111001101_0001010101010101_1100001101101011_00000000_00101011_00101011_00101011_0010111000011000_0101001111010000_1110101001110110_00000000_00000000_00000000_00000000_0000001111010110_0101001111010000_0100110010111111;
	#(`CYCLE)
	udp_triangle_valid = 0;
	wait(udp_proc_ready)
	for(i=0;i<`SRAM_SIZE;i=i+3)
	$fwrite(test_frame,"%h %h %h ",sram[i],sram[i+1],sram[i+2]);
	$finish;
end

initial	begin
	test_frame = $fopen("raster_test.txt","w");
	for(i=0;i<`SRAM_SIZE;i=i+1)
		sram[i] = 0;
end

assign	#(`CYCLE*2) udp_sram_data =  (!udp_sram_oe_n) ? sram[udp_sram_addr] : 'hz;

always@(posedge clk) begin
	if(!udp_sram_we_n) begin
	#(`CYCLE*2)
	sram[udp_sram_addr] = udp_sram_data;
	end
end


endmodule
