module	dibr(	input	clk,
				input	rst,
				output	[19:0]o_sram_addr,
				inout	[15:0]io_sram_data,
				output	o_sram_we_n,
				output	o_sram_oe_n,
				input	i_proc_finish,
				output	o_frame_finish
				);
				
	parameter	IDLE	=	0;
	parameter	WRITE	=	1;
	parameter	CHECK	=	2;
	parameter	DONE	=	3;
	
	reg		[1:0]	state,next_state; // change if needed
	reg		[7:0]	counter,next_counter;
	reg		[19:0]	sram_addr,next_sram_addr;
	reg		frame_finish;
	reg		sram_we_n;
	reg		sram_oe_n;
	reg		[15:0]	sram_rdata;
	reg		[15:0]	sram_wdata;

	assign		io_sram_data = (!o_sram_we_n) ? sram_wdata : 'hz; // write sram
	assign		o_frame_finish = frame_finish;
	assign		o_sram_addr = sram_addr;
	assign		o_sram_we_n = sram_we_n;
	assign		o_sram_oe_n = sram_oe_n;

	always@(*) begin
		next_state = state;
		next_counter = counter;
		next_sram_addr = sram_addr;
		frame_finish = 0;
		sram_we_n = 1;
		sram_oe_n = 1;
		sram_wdata = 0;
		sram_rdata = 'hz;
		case(state)
			IDLE:	begin
						next_state = i_proc_finish ? CHECK : state;
					end
			/*WRITE:	begin
						sram_we_n = 0;
						sram_wdata = 3*counter+1;
						next_sram_addr = counter == 8'hff ? 0 : sram_addr + 1;
						next_counter = counter == 8'hff ? 0 : counter + 1;
						next_state = counter == 8'hff ? CHECK : state;
					end*/
			CHECK:	begin
						sram_oe_n = 0;
						sram_rdata = io_sram_data;
						next_sram_addr = sram_addr + 1;
						next_counter = counter + 1;
						next_state = counter == 8'hff ? DONE : state;
					end
			DONE:	begin
						frame_finish = 1;
						next_counter = 0;
						next_sram_addr = 0;
						next_state = IDLE;
					end
		endcase
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state	<=	IDLE;
			counter	<=	0;
			sram_addr	<=	0;
		end
		else begin
			state	<=	next_state;
			counter	<=	next_counter;
			sram_addr	<=	next_sram_addr;
		end
	end

endmodule
