module IVB(	clk,
			reset,
			wen,
			wleft,
			wdata,
			//buffer interface
			rvalid,
			rdata
			);
	input	clk;
	input	reset;
	input	wen;
	input	wleft;
	input	[127:0]	wdata;
    output	rvalid;
    output	[255:0]	rdata;
	
	parameter	IDLE	=	0;
	parameter	LEFT	=	1;
	parameter	RIGHT	=	2;
	parameter	VALID	=	3;
	
	reg	[255:0]	IVB,next_IVB;
	reg	[1:0]	IVB_state,next_IVB_state;
	reg			rvalid,next_rvalid;
	
	assign	rdata = IVB;
	
	always@(*) begin
		next_IVB = IVB;
		next_IVB_state = IVB_state;
		next_rvalid = rvalid;
		case(IVB_state)
			IDLE:	begin
						if(wen) begin
							next_IVB[255:128] = wdata;
							next_IVB_state = LEFT;
						end
					end
			LEFT:	begin
						if(wen) begin
							next_IVB[127:0] = wdata;
							next_IVB_state = RIGHT;
						end
					end
			RIGHT:	begin
						next_rvalid = 1;
						next_IVB_state = VALID;
					end
			VALID:	begin
						next_rvalid = 0;
						if(wen) begin
							next_IVB[255:128] = wdata;
							next_IVB_state = LEFT;
						end
						else if(wdata[0]) begin//last signal
							next_IVB[255:128] = wdata;
							next_IVB_state = IDLE;
						end
					end
		endcase
	end
	
	always@(posedge clk or negedge reset) begin
		if(!reset) begin
			IVB	<=	0;
			IVB_state	<=	IDLE;
			rvalid		<=	0;
		end
		else begin
			IVB	<=	next_IVB;
			IVB_state	<=	next_IVB_state;
			rvalid		<=	next_rvalid;
		end
	end
	
endmodule