module TAG_STORAGE (


					iCLK,
					iRST_n,

					iSET_FREE,
					oTAG_OUT,
					iTAG_IN,
					oVALID,
					iGET,
					
					iSET_TAG_DCNT,
					iTAG_DCNT

					);
					
input 	iCLK;
input		iRST_n;


output	reg [31:0]oTAG_OUT;
input		iSET_FREE;
input		[31:0]iTAG_IN;
input		[15:0]iSET_TAG_DCNT;

output 	oVALID;
input		iGET;

input		[15:0]iTAG_DCNT;


//	reg	[15:0]tag_dcnt[0:31];
//	always@(posedge iCLK)
//		begin
//			if ( (iGET) & (oTAG_OUT == 0)	)
//				tag_dcnt[0] <= iTAG_DCNT;
//			else if (iSET_FREE & iTAG_IN == 0)
//				begin
//					if (tag_dcnt[0] <= iSET_TAG_DCNT )
//						tag_dcnt[0] <= 0;
//					else 
//						tag_dcnt[0] <= tag_dcnt[0] - iSET_TAG_DCNT;
//				end
//		end

reg	[15:0]tag_dcnt[0:31];
generate 
genvar i; 
  for (i=0; i<32; i=i+1) 
    begin : for_name 
			
		always@(posedge iCLK)
			begin
				if ( (iGET) & (oTAG_OUT == i)	)
					tag_dcnt[i] <= iTAG_DCNT;
				else if (iSET_FREE & iTAG_IN == i)
					begin
						if (tag_dcnt[i] <= iSET_TAG_DCNT )
							tag_dcnt[i] <= 0;
						else 
							tag_dcnt[i] <= tag_dcnt[i] - iSET_TAG_DCNT;
					end
			end

    end 
endgenerate	
	
//	reg	[31:0]tag_mem;
	always@(posedge iCLK)
		begin
			if (~iRST_n)
				oTAG_OUT <= 0;
			else if (tag_dcnt[0] == 1'b0)	oTAG_OUT <= 32'd0;
			else if (tag_dcnt[1] == 1'b0)	oTAG_OUT <= 32'd1;
			else if (tag_dcnt[2] == 1'b0)	oTAG_OUT <= 32'd2;
			else if (tag_dcnt[3] == 1'b0)	oTAG_OUT <= 32'd3;
			else if (tag_dcnt[4] == 1'b0)	oTAG_OUT <= 32'd4;
			else if (tag_dcnt[5] == 1'b0)	oTAG_OUT <= 32'd5;
			else if (tag_dcnt[6] == 1'b0)	oTAG_OUT <= 32'd6;
			else if (tag_dcnt[7] == 1'b0)	oTAG_OUT <= 32'd7;
			else if (tag_dcnt[8] == 1'b0)	oTAG_OUT <= 32'd8;
			else if (tag_dcnt[9] == 1'b0)	oTAG_OUT <= 32'd9;
			else if (tag_dcnt[10] == 1'b0)	oTAG_OUT <= 32'd10;
			else if (tag_dcnt[11] == 1'b0)	oTAG_OUT <= 32'd11;
			else if (tag_dcnt[12] == 1'b0)	oTAG_OUT <= 32'd12;
			else if (tag_dcnt[13] == 1'b0)	oTAG_OUT <= 32'd13;
			else if (tag_dcnt[14] == 1'b0)	oTAG_OUT <= 32'd14;
			else if (tag_dcnt[15] == 1'b0)	oTAG_OUT <= 32'd15;
			else if (tag_dcnt[16] == 1'b0)	oTAG_OUT <= 32'd16;
			else if (tag_dcnt[17] == 1'b0)	oTAG_OUT <= 32'd17;
			else if (tag_dcnt[18] == 1'b0)	oTAG_OUT <= 32'd18;
			else if (tag_dcnt[19] == 1'b0)	oTAG_OUT <= 32'd19;
			else if (tag_dcnt[20] == 1'b0)	oTAG_OUT <= 32'd20;
			else if (tag_dcnt[21] == 1'b0)	oTAG_OUT <= 32'd21;
			else if (tag_dcnt[22] == 1'b0)	oTAG_OUT <= 32'd22;
			else if (tag_dcnt[23] == 1'b0)	oTAG_OUT <= 32'd23;
			else if (tag_dcnt[24] == 1'b0)	oTAG_OUT <= 32'd24;
			else if (tag_dcnt[25] == 1'b0)	oTAG_OUT <= 32'd25;
			else if (tag_dcnt[26] == 1'b0)	oTAG_OUT <= 32'd26;
			else if (tag_dcnt[27] == 1'b0)	oTAG_OUT <= 32'd27;
			else if (tag_dcnt[28] == 1'b0)	oTAG_OUT <= 32'd28;
			else if (tag_dcnt[29] == 1'b0)	oTAG_OUT <= 32'd29;
			else if (tag_dcnt[30] == 1'b0)	oTAG_OUT <= 32'd30;
			else if (tag_dcnt[31] == 1'b0)	oTAG_OUT <= 32'd31;

		end
		
	assign oVALID = (
							
					 (tag_dcnt[0] !== 0) & (tag_dcnt[1] !== 0) & (tag_dcnt[2] !== 0) & (tag_dcnt[3] !== 0)
					&(tag_dcnt[4] !== 0) & (tag_dcnt[5] !== 0) & (tag_dcnt[6] !== 0) & (tag_dcnt[7] !== 0)
					&(tag_dcnt[8] !== 0) & (tag_dcnt[9] !== 0) & (tag_dcnt[10] !== 0) & (tag_dcnt[11] !== 0)
					&(tag_dcnt[12] !== 0) & (tag_dcnt[13] !== 0) & (tag_dcnt[14] !== 0) & (tag_dcnt[15] !== 0)
					&(tag_dcnt[16] !== 0) & (tag_dcnt[17] !== 0) & (tag_dcnt[18] !== 0) & (tag_dcnt[19] !== 0)
					&(tag_dcnt[20] !== 0) & (tag_dcnt[21] !== 0) & (tag_dcnt[22] !== 0) & (tag_dcnt[23] !== 0)
					&(tag_dcnt[24] !== 0) & (tag_dcnt[25] !== 0) & (tag_dcnt[26] !== 0) & (tag_dcnt[27] !== 0)
					&(tag_dcnt[28] !== 0) & (tag_dcnt[29] !== 0) & (tag_dcnt[30] !== 0) & (tag_dcnt[31] !== 0)
								
							)? 0 : 1;		
		
			
//	assign	oVALID = (tag_mem == 32'hffff_ffff)? 0 : 1;				
					
			
//generate 
//genvar j; 
//  for (j=0; j<32; j=j+1) 
//    begin : for_jname 
//		always@(posedge iCLK)
//			begin
//				if (~iRST_n)
//					tag_mem[j] <= 1'b0;
//				else if ( (iSET_FREE) & (iTAG_IN == j) )
//					tag_mem[j] <= 1'b0;
//				else if ( (iGET) & ( oTAG_OUT == j ) )
//					tag_mem[j] <= 1'b1;
//			end	
//    end 
//endgenerate			
					

					




endmodule


					