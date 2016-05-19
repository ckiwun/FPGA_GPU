//simulate the behavior of processor
module	pseudo_proc(
		input	clk,
		input	rst,
		// VBC interface
		input	i_triangle_valid,
		input	[255:0]i_triangle_data,
		output	o_proc_ready,
		// SRAM interface
		output	[20:1]o_sram_addr,
		inout	[15:0]io_sram_data,
		output	o_sram_we_n,
		output	o_sram_oe_n,
		output	o_proc_finish,
		// Debug
		output	[1:0]o_state,
		output	[3:0]o_counter
	);

	parameter	IDLE	=	0;
	parameter	PROCESS	=	1;
	parameter	DONE	=	2;
	
	reg	[1:0]	state,next_state;
	reg	[3:0]	counter,next_counter;
	reg			proc_ready;
	reg	[15:0]	write_data;
	
	wire	[15:0]	p0_x;
	wire	[15:0]	p0_y;
	wire	[15:0]	p0_z;
	wire	[7:0]		p0_r;
	wire	[7:0]		p0_g;
	wire	[7:0]		p0_b;
	wire	[7:0]		p0_a;
	wire	[15:0]	p1_x;
	wire	[15:0]	p1_y;
	wire	[15:0]	p1_z;
	wire	[7:0]		p1_r;
	wire	[7:0]		p1_g;
	wire	[7:0]		p1_b;
	wire	[7:0]		p1_a;
	wire	[15:0]	p2_x;
	wire	[15:0]	p2_y;
	wire	[15:0]	p2_z;
	wire	[7:0]		p2_r;
	wire	[7:0]		p2_g;
	wire	[7:0]		p2_b;
	wire	[7:0]		p2_a;
	wire	[15:0]	last;
	
	assign	o_proc_ready = proc_ready;
	assign	o_state = state;
	assign	o_counter = counter;
	//needs modify
	assign	o_sram_addr = 0;
	assign	io_sram_data = (!o_sram_we_n) ? write_data : 'hz;
	assign	o_sram_we_n = 1;
	assign	o_sram_oe_n = 1;
	assign	o_proc_finish = 0;
	
	assign	p0_x = i_triangle_data[15:0];
	assign	p0_y = i_triangle_data[31:16];
	assign	p0_z = i_triangle_data[47:32];
	assign	p0_r = i_triangle_data[55:48];
	assign	p0_g = i_triangle_data[63:56];
	assign	p0_b = i_triangle_data[71:64];
	assign	p0_a = i_triangle_data[79:72];
	assign	p1_x = i_triangle_data[95:80];
	assign	p1_y = i_triangle_data[111:96];
	assign	p1_z = i_triangle_data[127:112];
	assign	p1_r = i_triangle_data[135:128];
	assign	p1_g = i_triangle_data[143:136];
	assign	p1_b = i_triangle_data[151:144];
	assign	p1_a = i_triangle_data[159:152];
	assign	p2_x = i_triangle_data[175:160];
	assign	p2_y = i_triangle_data[191:176];
	assign	p2_z = i_triangle_data[207:192];
	assign	p2_r = i_triangle_data[215:208];
	assign	p2_g = i_triangle_data[223:216];
	assign	p2_b = i_triangle_data[231:224];
	assign	p2_a = i_triangle_data[239:232];
	assign	last = i_triangle_data[255:240];
				
	always@(*) begin
		next_state = state;
		next_counter = counter;
		proc_ready = 0;
		case(state)
			IDLE:		begin
							proc_ready = i_triangle_valid ? 0 : 1;
							next_state = i_triangle_valid ? PROCESS : state;
						end
			PROCESS:	begin
							next_counter = counter + 1;
							next_state = counter==4 ? DONE : state;
						end
			DONE:		begin
							next_counter = 0;
							next_state = IDLE;
						end
		endcase
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state	<=	IDLE;
			counter	<=	0;
		end
		else begin
			state	<=	next_state;
			counter	<=	next_counter;
		end
	end
	
endmodule
