`timescale 1ns/10ps
`define CYCLE 10
`define	SRAM_SIZE	320*480*4
`define	RGB_SIZE	320*480*3
`define	DEPTH_SIZE	320*480*3
`define	END_TIME	1000000
module test;

reg		clk;
reg		rst;

reg		[15:0]sram[`SRAM_SIZE-1:0];
reg		[15:0]next_sram[`SRAM_SIZE-1:0];
reg		[7:0]rgb[`RGB_SIZE-1:0];
reg		[7:0]depth[`DEPTH_SIZE-1:0];
integer	i;
integer	test_frame;

wire	[20:1]udp_sram_addr;
wire	[15:0]udp_sram_data;
wire	udp_sram_we_n;
wire	udp_sram_oe_n;
reg		udp_proc_finish;
wire	udp_frame_finish;

dibr	UDP(	.clk(clk),
				.rst(rst),
				.o_sram_addr(udp_sram_addr),
				.io_sram_data(udp_sram_data),
				.o_sram_we_n(udp_sram_we_n),
				.o_sram_oe_n(udp_sram_oe_n),
				.i_proc_finish(udp_proc_finish),
				.o_frame_finish(udp_frame_finish)
				);
initial begin
	clk = 0;
	rst = 0;
	udp_proc_finish = 0;
	#(`CYCLE*0.7) 	rst = 1;
	#(`CYCLE*1.3)	udp_proc_finish = 1;
	#(`CYCLE)		udp_proc_finish = 0;
	#(`END_TIME)	
	$display("something wrong with your code");
	$finish;
end

always begin #(`CYCLE*0.5) clk = ~clk; end

initial begin
	$fsdbDumpfile("dibr.fsdb");
	$fsdbDumpvars;
	//$fsdbDumpvars(0,test,"+mda");
	
end


initial	begin
	for(i=0;i<`SRAM_SIZE;i=i+1)
		sram[i] = 0;
	$readmemh ("view1.txt", rgb);
	$readmemh ("disp1.txt", depth);
	for(i=0;i<`RGB_SIZE;i=i+1)
		sram[i][7:0]=rgb[i];
	for(i=0;i<`DEPTH_SIZE;i=i+3)
		sram[`RGB_SIZE+i][7:0]=depth[i];
	$display("mem[%d] initialized with data %h\n",0,sram[0]);
	$display("mem[%d] initialized with data %h\n",1,sram[1]);
	test_frame = $fopen("test.txt","w");
end

initial begin
	wait(udp_frame_finish)
	for(i=0;i<`RGB_SIZE;i=i+3)
	$fwrite(test_frame,"%h %h %h ",sram[i][7:0],sram[i+1][7:0],sram[i+2][7:0]);
	$finish;
end

assign	#(`CYCLE) udp_sram_data =  (!udp_sram_oe_n) ? sram[udp_sram_addr] : 'hz;

always@(posedge clk) begin
	if(!udp_sram_we_n&udp_sram_oe_n)
	sram[udp_sram_addr] <= udp_sram_data;
end



endmodule