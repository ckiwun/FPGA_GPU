module	ssram_controller(	input	clk,
							input	rst,
							// VBC Interface
							input	i_vbc_triangle_valid,
							// RASTER Interface
							input	[19:0]i_raster_sram_addr,
							inout	[15:0]io_raster_sram_data,
							input	i_raster_sram_we_n,
							input	i_raster_sram_oe_n,
							input	i_raster_finish,
							// DIBR Interface
							input	[19:0]i_dibr_sram_addr,
							inout	[15:0]io_dibr_sram_data,
							input	i_dibr_sram_we_n,
							input	i_dibr_sram_oe_n,
							input	i_dibr_finish,
							// DVI Interface
							input	[19:0]i_dvi_sram_addr,
							inout	[15:0]io_dvi_sram_data,
							input	i_dvi_sram_we_n,
							input	i_dvi_sram_oe_n,
							input	i_dvi_finish,
							// SSRAM Interface
							output	[19:0]o_sram_addr,
							inout	[15:0]io_sram_data,
							output	o_sram_we_n,
							output	o_sram_oe_n
							);
							
	parameter	IDLE	=	0;
	parameter	RASTER	=	1;
	parameter	DIBR	=	2;
	parameter	DVI		=	3;
	
	reg	[1:0]	state,next_state;
	reg	[19:0]	initial_sram_addr,next_initial_sram_addr;
	
	reg	[19:0]	sram_addr;
	reg	[15:0]	sram_wdata;
	reg	[15:0]	sram_rdata;
	reg			sram_we_n;
	reg			sram_oe_n;
	
	assign		io_raster_sram_data = (!i_raster_sram_oe_n) ? sram_rdata : 'hz;
	assign		io_dibr_sram_data = (!i_dibr_sram_oe_n) ? sram_rdata : 'hz;
	assign		io_dvi_sram_data = (!i_dvi_sram_oe_n) ? sram_rdata : 'hz;
	
	assign		o_sram_addr	= sram_addr;
	assign		io_sram_data = (!sram_we_n) ? sram_wdata : 'hz;
	assign		o_sram_we_n = sram_we_n;
	assign		o_sram_oe_n = sram_oe_n;
	
	always@(*) begin
		next_initial_sram_addr = initial_sram_addr;
		case(state)
			IDLE:	begin
						sram_addr = initial_sram_addr;
						sram_wdata = 16'hffff;
						sram_we_n = 0;
						sram_oe_n = 1;
						next_initial_sram_addr = initial_sram_addr==20'd614399 ? initial_sram_addr : initial_sram_addr + 1;
						next_state = i_vbc_triangle_valid ? RASTER : state;
					end
			RASTER:	begin
						sram_addr = i_raster_sram_addr;
						sram_wdata = io_raster_sram_data;
						sram_we_n = i_raster_sram_we_n;
						sram_oe_n = i_raster_sram_oe_n;
						next_initial_sram_addr = 0;
						next_state = i_raster_finish ? DIBR : state;
					end
			DIBR:	begin
						sram_addr = i_dibr_sram_addr;
						sram_wdata = io_dibr_sram_data;
						sram_we_n = i_dibr_sram_we_n;
						sram_oe_n = i_dibr_sram_oe_n;
						next_state = i_dibr_finish ? DVI : state;
					end
			DVI:	begin
						sram_addr = i_dvi_sram_addr;
						sram_wdata = io_dvi_sram_data;
						sram_we_n = i_dvi_sram_we_n;
						sram_oe_n = i_dvi_sram_oe_n;
						next_state = i_dvi_finish ? IDLE : state;
					end
		endcase
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state	<=	IDLE;
			initial_sram_addr	<=	0;
		end
		else begin
			state	<=	next_state;
			initial_sram_addr	<=	next_initial_sram_addr;
		end
	end

endmodule
