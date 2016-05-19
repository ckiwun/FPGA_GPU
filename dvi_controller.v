module	dvi_controller(	input	clk,
						input	rst,
						output	[19:0]o_sram_addr,
						inout	[15:0]io_sram_data,
						output	o_sram_we_n,
						output	o_sram_oe_n,
						input	i_vpg_pre_valid,
						input	i_frame_finish,
						output	[23:0]o_rgb,
						output	o_dvi_finish
						);
			
		
	// SRAM Interface
	parameter	IDLE	=	0;
	parameter	SYNC	=	1;
	parameter	RDLEFT	=	2;
	parameter	RDRIGHT	=	3;
	parameter	LNDONE	=	4;
	parameter	FMDONE	=	5;
	
	reg		[2:0]	state,next_state; // change if needed
	reg		[9:0]	counter,next_counter;
	reg		[19:0]	sram_addr,next_sram_addr;
	reg		[15:0]	rgb,next_rgb;
	reg		dvi_finish;
	reg		sram_we_n;
	reg		sram_oe_n;
	wire	[7:0]	r;
	wire	[7:0]	g;
	wire	[7:0]	b;
	//reg		[15:0]	sram_rdata;
	reg		[15:0]	sram_wdata;
	//wire	[9:0]	coor_x;
	wire	[9:0]	coor_y;

	assign		io_sram_data = (!o_sram_we_n) ? sram_wdata : 'hz; // write sram
	assign		o_dvi_finish = dvi_finish;
	assign		o_sram_addr = sram_addr;
	assign		o_sram_we_n = sram_we_n;
	assign		o_sram_oe_n = sram_oe_n;
	assign		r = {rgb[15:11],{3'b0}};
	assign		g = {rgb[10:5],{2'b0}};
	assign		b = {rgb[4:0],{3'b0}};
	assign		o_rgb = {r,g,b};
	//assign		coor_x = sram_addr%320;
	assign		coor_y = sram_addr/320;
	
	always@(*) begin
		next_state = state;
		next_counter = counter;
		next_sram_addr = sram_addr;
		next_rgb = rgb;
		dvi_finish = 0;
		sram_we_n = 1;
		sram_oe_n = 1;
		sram_wdata = 0;
		//sram_rdata = 'hz;
		case(state)
			IDLE:	begin
						next_state = i_frame_finish&(!i_vpg_pre_valid) ? SYNC : state;
					end
			SYNC:	begin
						sram_oe_n = i_vpg_pre_valid ? 0 : 1;
						next_sram_addr = i_vpg_pre_valid ? sram_addr + 1 : sram_addr;
						next_state = i_vpg_pre_valid ? RDLEFT : state;
					end
			RDLEFT:	begin
						sram_oe_n = 0;
						next_rgb = (counter!=0) ? io_sram_data : rgb;
						next_sram_addr = (counter == 10'd318) ? (sram_addr+320*479+1) : sram_addr + 1;
						next_counter = counter + 1;
						next_state = counter == 10'd318 ? RDRIGHT : state;
					end
			RDRIGHT:begin
						sram_oe_n = 0;
						next_rgb = io_sram_data;
						next_sram_addr = counter == 10'd638 ? sram_addr-153599 : sram_addr + 1;
						next_counter = counter + 1;
						next_state = counter == 10'd638 ? LNDONE : state;
					end
			LNDONE:	begin
						next_counter = 0;
						next_state = coor_y==480? FMDONE : SYNC;
					end
			FMDONE:	begin
						next_rgb = 0;
						next_sram_addr = 0;
						next_counter = 0;
						next_state = SYNC;
					end
		endcase
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state	<=	IDLE;
			counter	<=	0;
			sram_addr	<=	0;
			rgb		<=	0;
		end
		else begin
			state	<=	next_state;
			counter	<=	next_counter;
			sram_addr	<=	next_sram_addr;
			rgb		<=	next_rgb;
		end
	end

	
endmodule
