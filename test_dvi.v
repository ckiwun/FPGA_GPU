`timescale 1ns/10ps
`define CYCLE		10
`define	SRAM_SIZE	320*480*3
`define	RGB_SIZE	320*480
`define	DEPTH_SIZE	320*480
`define	HALF_WIDTH	320
`define	WIDTH		640
`define	END_TIME	10000000
module test;

reg		clk;
reg		rst;

reg		[15:0]sram[`SRAM_SIZE-1:0];
reg		[7:0]rgb[`SRAM_SIZE-1:0];
reg		[7:0]depth[`SRAM_SIZE-1:0];
integer	i;
integer	test_frame;

wire	[20:1]udp_sram_addr;
wire	[15:0]udp_sram_data;
reg		[15:0]sram_data;
wire	udp_sram_we_n;
wire	udp_sram_oe_n;
reg		udp_frame_finish;
reg		udp_vpg_pre_valid;
wire	udp_dvi_finish;

dvi_controller	UDP(	.clk(clk),
						.rst(rst),
						.o_sram_addr(udp_sram_addr),
						.io_sram_data(udp_sram_data),
						.o_sram_we_n(udp_sram_we_n),
						.o_sram_oe_n(udp_sram_oe_n),
						.i_frame_finish(udp_frame_finish),
						.i_vpg_pre_valid(udp_vpg_pre_valid),
						.o_dvi_finish(udp_dvi_finish)
						);
initial begin
	clk = 0;
	rst = 0;
	udp_frame_finish = 0;
	udp_vpg_pre_valid = 0;
	#(`CYCLE*0.7) 	rst = 1;
	#(`CYCLE*1.8)	udp_frame_finish = 1;
	#(`CYCLE)		udp_frame_finish = 0;
	while(UDP.coor_y!=960) begin
		if(UDP.state==5) begin
		#(`CYCLE*320*12) udp_vpg_pre_valid = 1;
		end
		else begin
		#(`CYCLE*(96+40+8))udp_vpg_pre_valid = 1;
		end
		#(`CYCLE*`WIDTH)	udp_vpg_pre_valid = 0;
		
	end
end

always begin #(`CYCLE*0.5) clk = ~clk; end

initial begin
	$fsdbDumpfile("dvi.fsdb");
	$fsdbDumpvars;
	//$fsdbDumpvars(0,test,"+mda");
	
end


initial	begin
	for(i=0;i<`SRAM_SIZE;i=i+1)
		sram[i] = 0;
	$readmemh ("view1.txt", rgb);
	$readmemh ("disp1.txt", depth);
	for(i=0;i<`RGB_SIZE;i=i+1)
		sram[i]={rgb[3*i][7:3],rgb[3*i+1][7:2],rgb[3*i+2][7:3]};
	for(i=0;i<`RGB_SIZE;i=i+1)
		sram[`RGB_SIZE+i]={rgb[3*i][7:3],rgb[3*i+1][7:2],rgb[3*i+2][7:3]};
	for(i=0;i<`DEPTH_SIZE;i=i+1)
		sram[`RGB_SIZE*2+i][7:0]=depth[3*i];
	$display("mem[%d] initialized with data %h\n",0,sram[0]);
	$display("mem[%d] initialized with data %h\n",1,sram[1]);
end


initial begin
	#(`END_TIME)	
	$finish;
end

assign	udp_sram_data =  sram_data;

always@(negedge clk) begin
	if(!udp_sram_we_n&udp_sram_oe_n)
	#(`CYCLE*2)	sram[udp_sram_addr] <= udp_sram_data;
	else if(!udp_sram_oe_n)
	sram_data <= #(`CYCLE*2) sram[udp_sram_addr];
	else
	sram_data <= #(`CYCLE*2) 'hz;
end



endmodule