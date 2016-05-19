module	VBC(
		input clk,
		input rst,
		// PCIE interface
		input i_pcie_dmawr_write,
		input [12:0]i_pcie_dmawr_addr,
		input [127:0]i_pcie_dmawr_data,
		input i_pcie_dmard_read,
		input [12:0]i_pcie_dmard_addr,
		output reg [127:0]o_pcie_dmard_data,
		// Vertex Buffer Interface
		output reg o_ram1_wren,
		output reg[12:0]o_ram1_wraddress,
		output reg[127:0]o_ram1_data,
		output reg o_ram1_rden,
		output reg [12:0]o_ram1_rdaddress,
		input [127:0]i_ram1_q,
		// Processing Unit Interface
		input i_proc_ready,
		output reg o_triangle_valid,
		output [255:0]o_triangle_data
	);

	parameter	IDLE		= 0;
	parameter	WRITE		= 1;
	parameter	WAIT		= 2;
	parameter	PREPARE		= 3;
	
	reg	[1:0]	state,next_state;
	reg			frame_finish,next_frame_finish;
	reg	[1:0]	counter,next_counter;//0 for prepare [255:128], 1 for prepare [127:0], 2 for jump to IDLE
	reg	[255:0]	triangle_data,next_triangle_data;
	reg	[12:0]	read_addr,next_read_addr;
	
	wire		write_last_signal;
	assign		write_last_signal = i_pcie_dmawr_addr[0]&i_pcie_dmawr_data[0];
	wire		read_last_signal;
	assign		read_last_signal = triangle_data[0];
	
	assign		o_frame_done = read_last_signal;
	assign		o_triangle_data = triangle_data;
	
	always@(*) begin
		next_state = state;
		next_frame_finish = frame_finish;
		next_counter = counter;
		next_triangle_data = triangle_data;
		next_read_addr = read_addr;
		o_ram1_wren = i_pcie_dmawr_write;
		o_ram1_wraddress = i_pcie_dmawr_addr;
		o_ram1_data = i_pcie_dmawr_data;
		o_ram1_rden = i_pcie_dmard_read;
		o_ram1_rdaddress = i_pcie_dmard_addr;
		o_pcie_dmard_data = i_ram1_q;
		o_triangle_valid = 0;
		case(state)
			IDLE:		begin
							next_state = i_pcie_dmawr_write ? WRITE : state;
						end
			WRITE:		begin
							next_frame_finish = 0;
							next_read_addr = 0;
							next_state = write_last_signal ? WAIT : state;
						end
			WAIT:		begin
							o_ram1_rden = i_proc_ready ? 1 : 0;
							o_ram1_rdaddress = read_addr;
							next_counter = 0;
							next_read_addr = i_proc_ready ? read_addr + 1 : read_addr;
							next_state = i_proc_ready ? PREPARE : frame_finish ? IDLE : state;
						end
			PREPARE:	begin
							case(counter)
								0:	begin
										o_ram1_rden = 1;
										o_ram1_rdaddress = read_addr;
										next_triangle[255:128] = i_ram1_q;//assume data read latency is 1 cycle
										next_read_addr = read_addr + 1;
										next_counter = counter + 1;
									end
								1:	begin
										next_triangle[127:0] = i_ram1_q;
										next_counter = counter + 1;
									end
							endcase
							o_triangle_valid = counter==2 ? 1 : 0;
							next_frame_finish = read_last_signal ? 1 : frame_finish;
							next_state = counter==2 ? WAIT : state;
						end
		endcase
	end
	
	always@(posedge clk or negedge rst) begin
		if(!rst) begin
			state	<=	IDLE;
			frame_finish	<=	0;
			counter	<=	0;
			triangle_data	<=	0;
			read_addr	<=	0;
		end
		else begin
			state	<=	next_state;
			frame_finish	<=	next_frame_finish;
			counter <=	next_counter;
			triangle_data	<=	next_triangle_data;
			read_addr	<=	next_read_addr;
		end
	end
	
endmodule
