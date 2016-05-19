module sort(clk,
			rst,
			pixel_in0,
			pixel_in1,
			pixel_in2,
			pixel_in3,
			pixel_in4,
			pixel_in5,
			pixel_in6,
			pixel_in7,
			pixel_in8,
			pixel_out
			);
			
input clk,rst;
input [7:0] pixel_in0;
input [7:0] pixel_in1;
input [7:0] pixel_in2;
input [7:0] pixel_in3;
input [7:0] pixel_in4;
input [7:0] pixel_in5;
input [7:0] pixel_in6;
input [7:0] pixel_in7;
input [7:0] pixel_in8;
output [7:0] pixel_out;

reg [7:0] pixel [8:0]; // for convenience
always@(*) begin
	pixel[0][7:0]=pixel_in0[7:0];
	pixel[1][7:0]=pixel_in1[7:0];
	pixel[2][7:0]=pixel_in2[7:0];
	pixel[3][7:0]=pixel_in3[7:0];
	pixel[4][7:0]=pixel_in4[7:0];
	pixel[5][7:0]=pixel_in5[7:0];
	pixel[6][7:0]=pixel_in6[7:0];
	pixel[7][7:0]=pixel_in7[7:0];
	pixel[8][7:0]=pixel_in8[7:0];
end
//greater
wire	[7:0]	is_p0_greater_than;
wire	[7:0]	is_p1_greater_than;
wire	[7:0]	is_p2_greater_than;
wire	[7:0]	is_p3_greater_than;
wire	[7:0]	is_p4_greater_than;
wire	[7:0]	is_p5_greater_than;
wire	[7:0]	is_p6_greater_than;
wire	[7:0]	is_p7_greater_than;
wire	[7:0]	is_p8_greater_than;

assign	is_p0_greater_than[0] = pixel[0] > pixel[1] ? 1 : 0;
assign	is_p0_greater_than[1] = pixel[0] > pixel[2] ? 1 : 0;
assign	is_p0_greater_than[2] = pixel[0] > pixel[3] ? 1 : 0;
assign	is_p0_greater_than[3] = pixel[0] > pixel[4] ? 1 : 0;
assign	is_p0_greater_than[4] = pixel[0] > pixel[5] ? 1 : 0;
assign	is_p0_greater_than[5] = pixel[0] > pixel[6] ? 1 : 0;
assign	is_p0_greater_than[6] = pixel[0] > pixel[7] ? 1 : 0;
assign	is_p0_greater_than[7] = pixel[0] > pixel[8] ? 1 : 0;

assign	is_p1_greater_than[0] = pixel[1] > pixel[0] ? 1 : 0;
assign	is_p1_greater_than[1] = pixel[1] > pixel[2] ? 1 : 0;
assign	is_p1_greater_than[2] = pixel[1] > pixel[3] ? 1 : 0;
assign	is_p1_greater_than[3] = pixel[1] > pixel[4] ? 1 : 0;
assign	is_p1_greater_than[4] = pixel[1] > pixel[5] ? 1 : 0;
assign	is_p1_greater_than[5] = pixel[1] > pixel[6] ? 1 : 0;
assign	is_p1_greater_than[6] = pixel[1] > pixel[7] ? 1 : 0;
assign	is_p1_greater_than[7] = pixel[1] > pixel[8] ? 1 : 0;

assign	is_p2_greater_than[0] = pixel[2] > pixel[1] ? 1 : 0;
assign	is_p2_greater_than[1] = pixel[2] > pixel[0] ? 1 : 0;
assign	is_p2_greater_than[2] = pixel[2] > pixel[3] ? 1 : 0;
assign	is_p2_greater_than[3] = pixel[2] > pixel[4] ? 1 : 0;
assign	is_p2_greater_than[4] = pixel[2] > pixel[5] ? 1 : 0;
assign	is_p2_greater_than[5] = pixel[2] > pixel[6] ? 1 : 0;
assign	is_p2_greater_than[6] = pixel[2] > pixel[7] ? 1 : 0;
assign	is_p2_greater_than[7] = pixel[2] > pixel[8] ? 1 : 0;

assign	is_p3_greater_than[0] = pixel[3] > pixel[1] ? 1 : 0;
assign	is_p3_greater_than[1] = pixel[3] > pixel[2] ? 1 : 0;
assign	is_p3_greater_than[2] = pixel[3] > pixel[0] ? 1 : 0;
assign	is_p3_greater_than[3] = pixel[3] > pixel[4] ? 1 : 0;
assign	is_p3_greater_than[4] = pixel[3] > pixel[5] ? 1 : 0;
assign	is_p3_greater_than[5] = pixel[3] > pixel[6] ? 1 : 0;
assign	is_p3_greater_than[6] = pixel[3] > pixel[7] ? 1 : 0;
assign	is_p3_greater_than[7] = pixel[3] > pixel[8] ? 1 : 0;

assign	is_p4_greater_than[0] = pixel[4] > pixel[1] ? 1 : 0;
assign	is_p4_greater_than[1] = pixel[4] > pixel[2] ? 1 : 0;
assign	is_p4_greater_than[2] = pixel[4] > pixel[3] ? 1 : 0;
assign	is_p4_greater_than[3] = pixel[4] > pixel[0] ? 1 : 0;
assign	is_p4_greater_than[4] = pixel[4] > pixel[5] ? 1 : 0;
assign	is_p4_greater_than[5] = pixel[4] > pixel[6] ? 1 : 0;
assign	is_p4_greater_than[6] = pixel[4] > pixel[7] ? 1 : 0;
assign	is_p4_greater_than[7] = pixel[4] > pixel[8] ? 1 : 0;

assign	is_p5_greater_than[0] = pixel[5] > pixel[1] ? 1 : 0;
assign	is_p5_greater_than[1] = pixel[5] > pixel[2] ? 1 : 0;
assign	is_p5_greater_than[2] = pixel[5] > pixel[3] ? 1 : 0;
assign	is_p5_greater_than[3] = pixel[5] > pixel[4] ? 1 : 0;
assign	is_p5_greater_than[4] = pixel[5] > pixel[0] ? 1 : 0;
assign	is_p5_greater_than[5] = pixel[5] > pixel[6] ? 1 : 0;
assign	is_p5_greater_than[6] = pixel[5] > pixel[7] ? 1 : 0;
assign	is_p5_greater_than[7] = pixel[5] > pixel[8] ? 1 : 0;

assign	is_p6_greater_than[0] = pixel[6] > pixel[1] ? 1 : 0;
assign	is_p6_greater_than[1] = pixel[6] > pixel[2] ? 1 : 0;
assign	is_p6_greater_than[2] = pixel[6] > pixel[3] ? 1 : 0;
assign	is_p6_greater_than[3] = pixel[6] > pixel[4] ? 1 : 0;
assign	is_p6_greater_than[4] = pixel[6] > pixel[5] ? 1 : 0;
assign	is_p6_greater_than[5] = pixel[6] > pixel[0] ? 1 : 0;
assign	is_p6_greater_than[6] = pixel[6] > pixel[7] ? 1 : 0;
assign	is_p6_greater_than[7] = pixel[6] > pixel[8] ? 1 : 0;

assign	is_p7_greater_than[0] = pixel[7] > pixel[1] ? 1 : 0;
assign	is_p7_greater_than[1] = pixel[7] > pixel[2] ? 1 : 0;
assign	is_p7_greater_than[2] = pixel[7] > pixel[3] ? 1 : 0;
assign	is_p7_greater_than[3] = pixel[7] > pixel[4] ? 1 : 0;
assign	is_p7_greater_than[4] = pixel[7] > pixel[5] ? 1 : 0;
assign	is_p7_greater_than[5] = pixel[7] > pixel[6] ? 1 : 0;
assign	is_p7_greater_than[6] = pixel[7] > pixel[0] ? 1 : 0;
assign	is_p7_greater_than[7] = pixel[7] > pixel[8] ? 1 : 0;

assign	is_p8_greater_than[0] = pixel[8] > pixel[1] ? 1 : 0;
assign	is_p8_greater_than[1] = pixel[8] > pixel[2] ? 1 : 0;
assign	is_p8_greater_than[2] = pixel[8] > pixel[3] ? 1 : 0;
assign	is_p8_greater_than[3] = pixel[8] > pixel[4] ? 1 : 0;
assign	is_p8_greater_than[4] = pixel[8] > pixel[5] ? 1 : 0;
assign	is_p8_greater_than[5] = pixel[8] > pixel[6] ? 1 : 0;
assign	is_p8_greater_than[6] = pixel[8] > pixel[7] ? 1 : 0;
assign	is_p8_greater_than[7] = pixel[8] > pixel[0] ? 1 : 0;
//equal
wire	[7:0]	is_p0_equal_to;
wire	[7:0]	is_p1_equal_to;
wire	[7:0]	is_p2_equal_to;
wire	[7:0]	is_p3_equal_to;
wire	[7:0]	is_p4_equal_to;
wire	[7:0]	is_p5_equal_to;
wire	[7:0]	is_p6_equal_to;
wire	[7:0]	is_p7_equal_to;
wire	[7:0]	is_p8_equal_to;

assign	is_p0_equal_to[0] = pixel[0] == pixel[1] ? 1 : 0;
assign	is_p0_equal_to[1] = pixel[0] == pixel[2] ? 1 : 0;
assign	is_p0_equal_to[2] = pixel[0] == pixel[3] ? 1 : 0;
assign	is_p0_equal_to[3] = pixel[0] == pixel[4] ? 1 : 0;
assign	is_p0_equal_to[4] = pixel[0] == pixel[5] ? 1 : 0;
assign	is_p0_equal_to[5] = pixel[0] == pixel[6] ? 1 : 0;
assign	is_p0_equal_to[6] = pixel[0] == pixel[7] ? 1 : 0;
assign	is_p0_equal_to[7] = pixel[0] == pixel[8] ? 1 : 0;

assign	is_p1_equal_to[0] = pixel[1] == pixel[0] ? 1 : 0;
assign	is_p1_equal_to[1] = pixel[1] == pixel[2] ? 1 : 0;
assign	is_p1_equal_to[2] = pixel[1] == pixel[3] ? 1 : 0;
assign	is_p1_equal_to[3] = pixel[1] == pixel[4] ? 1 : 0;
assign	is_p1_equal_to[4] = pixel[1] == pixel[5] ? 1 : 0;
assign	is_p1_equal_to[5] = pixel[1] == pixel[6] ? 1 : 0;
assign	is_p1_equal_to[6] = pixel[1] == pixel[7] ? 1 : 0;
assign	is_p1_equal_to[7] = pixel[1] == pixel[8] ? 1 : 0;

assign	is_p2_equal_to[0] = pixel[2] == pixel[1] ? 1 : 0;
assign	is_p2_equal_to[1] = pixel[2] == pixel[0] ? 1 : 0;
assign	is_p2_equal_to[2] = pixel[2] == pixel[3] ? 1 : 0;
assign	is_p2_equal_to[3] = pixel[2] == pixel[4] ? 1 : 0;
assign	is_p2_equal_to[4] = pixel[2] == pixel[5] ? 1 : 0;
assign	is_p2_equal_to[5] = pixel[2] == pixel[6] ? 1 : 0;
assign	is_p2_equal_to[6] = pixel[2] == pixel[7] ? 1 : 0;
assign	is_p2_equal_to[7] = pixel[2] == pixel[8] ? 1 : 0;

assign	is_p3_equal_to[0] = pixel[3] == pixel[1] ? 1 : 0;
assign	is_p3_equal_to[1] = pixel[3] == pixel[2] ? 1 : 0;
assign	is_p3_equal_to[2] = pixel[3] == pixel[0] ? 1 : 0;
assign	is_p3_equal_to[3] = pixel[3] == pixel[4] ? 1 : 0;
assign	is_p3_equal_to[4] = pixel[3] == pixel[5] ? 1 : 0;
assign	is_p3_equal_to[5] = pixel[3] == pixel[6] ? 1 : 0;
assign	is_p3_equal_to[6] = pixel[3] == pixel[7] ? 1 : 0;
assign	is_p3_equal_to[7] = pixel[3] == pixel[8] ? 1 : 0;

assign	is_p4_equal_to[0] = pixel[4] == pixel[1] ? 1 : 0;
assign	is_p4_equal_to[1] = pixel[4] == pixel[2] ? 1 : 0;
assign	is_p4_equal_to[2] = pixel[4] == pixel[3] ? 1 : 0;
assign	is_p4_equal_to[3] = pixel[4] == pixel[0] ? 1 : 0;
assign	is_p4_equal_to[4] = pixel[4] == pixel[5] ? 1 : 0;
assign	is_p4_equal_to[5] = pixel[4] == pixel[6] ? 1 : 0;
assign	is_p4_equal_to[6] = pixel[4] == pixel[7] ? 1 : 0;
assign	is_p4_equal_to[7] = pixel[4] == pixel[8] ? 1 : 0;

assign	is_p5_equal_to[0] = pixel[5] == pixel[1] ? 1 : 0;
assign	is_p5_equal_to[1] = pixel[5] == pixel[2] ? 1 : 0;
assign	is_p5_equal_to[2] = pixel[5] == pixel[3] ? 1 : 0;
assign	is_p5_equal_to[3] = pixel[5] == pixel[4] ? 1 : 0;
assign	is_p5_equal_to[4] = pixel[5] == pixel[0] ? 1 : 0;
assign	is_p5_equal_to[5] = pixel[5] == pixel[6] ? 1 : 0;
assign	is_p5_equal_to[6] = pixel[5] == pixel[7] ? 1 : 0;
assign	is_p5_equal_to[7] = pixel[5] == pixel[8] ? 1 : 0;

assign	is_p6_equal_to[0] = pixel[6] == pixel[1] ? 1 : 0;
assign	is_p6_equal_to[1] = pixel[6] == pixel[2] ? 1 : 0;
assign	is_p6_equal_to[2] = pixel[6] == pixel[3] ? 1 : 0;
assign	is_p6_equal_to[3] = pixel[6] == pixel[4] ? 1 : 0;
assign	is_p6_equal_to[4] = pixel[6] == pixel[5] ? 1 : 0;
assign	is_p6_equal_to[5] = pixel[6] == pixel[0] ? 1 : 0;
assign	is_p6_equal_to[6] = pixel[6] == pixel[7] ? 1 : 0;
assign	is_p6_equal_to[7] = pixel[6] == pixel[8] ? 1 : 0;

assign	is_p7_equal_to[0] = pixel[7] == pixel[1] ? 1 : 0;
assign	is_p7_equal_to[1] = pixel[7] == pixel[2] ? 1 : 0;
assign	is_p7_equal_to[2] = pixel[7] == pixel[3] ? 1 : 0;
assign	is_p7_equal_to[3] = pixel[7] == pixel[4] ? 1 : 0;
assign	is_p7_equal_to[4] = pixel[7] == pixel[5] ? 1 : 0;
assign	is_p7_equal_to[5] = pixel[7] == pixel[6] ? 1 : 0;
assign	is_p7_equal_to[6] = pixel[7] == pixel[0] ? 1 : 0;
assign	is_p7_equal_to[7] = pixel[7] == pixel[8] ? 1 : 0;

assign	is_p8_equal_to[0] = pixel[8] == pixel[1] ? 1 : 0;
assign	is_p8_equal_to[1] = pixel[8] == pixel[2] ? 1 : 0;
assign	is_p8_equal_to[2] = pixel[8] == pixel[3] ? 1 : 0;
assign	is_p8_equal_to[3] = pixel[8] == pixel[4] ? 1 : 0;
assign	is_p8_equal_to[4] = pixel[8] == pixel[5] ? 1 : 0;
assign	is_p8_equal_to[5] = pixel[8] == pixel[6] ? 1 : 0;
assign	is_p8_equal_to[6] = pixel[8] == pixel[7] ? 1 : 0;
assign	is_p8_equal_to[7] = pixel[8] == pixel[0] ? 1 : 0;
//lower sum
wire	[3:0]	p0_lower_sum;
wire	[3:0]	p1_lower_sum;
wire	[3:0]	p2_lower_sum;
wire	[3:0]	p3_lower_sum;
wire	[3:0]	p4_lower_sum;
wire	[3:0]	p5_lower_sum;
wire	[3:0]	p6_lower_sum;
wire	[3:0]	p7_lower_sum;
wire	[3:0]	p8_lower_sum;

assign	p0_lower_sum = 	is_p0_greater_than[0] + is_p0_greater_than[1] + is_p0_greater_than[2] +
						is_p0_greater_than[3] + is_p0_greater_than[4] + is_p0_greater_than[5] +
						is_p0_greater_than[6] + is_p0_greater_than[7] ;
assign	p1_lower_sum = 	is_p1_greater_than[0] + is_p1_greater_than[1] + is_p1_greater_than[2] +
						is_p1_greater_than[3] + is_p1_greater_than[4] + is_p1_greater_than[5] +
						is_p1_greater_than[6] + is_p1_greater_than[7] ;
assign	p2_lower_sum = 	is_p2_greater_than[0] + is_p2_greater_than[1] + is_p2_greater_than[2] +
						is_p2_greater_than[3] + is_p2_greater_than[4] + is_p2_greater_than[5] +
						is_p2_greater_than[6] + is_p2_greater_than[7] ;
assign	p3_lower_sum = 	is_p3_greater_than[0] + is_p3_greater_than[1] + is_p3_greater_than[2] +
						is_p3_greater_than[3] + is_p3_greater_than[4] + is_p3_greater_than[5] +
						is_p3_greater_than[6] + is_p3_greater_than[7] ;
assign	p4_lower_sum = 	is_p4_greater_than[0] + is_p4_greater_than[1] + is_p4_greater_than[2] +
						is_p4_greater_than[3] + is_p4_greater_than[4] + is_p4_greater_than[5] +
						is_p4_greater_than[6] + is_p4_greater_than[7] ;
assign	p5_lower_sum = 	is_p5_greater_than[0] + is_p5_greater_than[1] + is_p5_greater_than[2] +
						is_p5_greater_than[3] + is_p5_greater_than[4] + is_p5_greater_than[5] +
						is_p5_greater_than[6] + is_p5_greater_than[7] ;
assign	p6_lower_sum = 	is_p6_greater_than[0] + is_p6_greater_than[1] + is_p6_greater_than[2] +
						is_p6_greater_than[3] + is_p6_greater_than[4] + is_p6_greater_than[5] +
						is_p6_greater_than[6] + is_p6_greater_than[7] ;
assign	p7_lower_sum = 	is_p7_greater_than[0] + is_p7_greater_than[1] + is_p7_greater_than[2] +
						is_p7_greater_than[3] + is_p7_greater_than[4] + is_p7_greater_than[5] +
						is_p7_greater_than[6] + is_p7_greater_than[7] ;
assign	p8_lower_sum = 	is_p8_greater_than[0] + is_p8_greater_than[1] + is_p8_greater_than[2] +
						is_p8_greater_than[3] + is_p8_greater_than[4] + is_p8_greater_than[5] +
						is_p8_greater_than[6] + is_p8_greater_than[7] ;

//upper sum
wire	[3:0]	p0_upper_sum;
wire	[3:0]	p1_upper_sum;
wire	[3:0]	p2_upper_sum;
wire	[3:0]	p3_upper_sum;
wire	[3:0]	p4_upper_sum;
wire	[3:0]	p5_upper_sum;
wire	[3:0]	p6_upper_sum;
wire	[3:0]	p7_upper_sum;
wire	[3:0]	p8_upper_sum;

assign	p0_upper_sum = 	is_p0_equal_to[0] + is_p0_equal_to[1] + is_p0_equal_to[2] +
						is_p0_equal_to[3] + is_p0_equal_to[4] + is_p0_equal_to[5] +
						is_p0_equal_to[6] + is_p0_equal_to[7] ;
assign	p1_upper_sum = 	is_p1_equal_to[0] + is_p1_equal_to[1] + is_p1_equal_to[2] +
						is_p1_equal_to[3] + is_p1_equal_to[4] + is_p1_equal_to[5] +
						is_p1_equal_to[6] + is_p1_equal_to[7] ;
assign	p2_upper_sum = 	is_p2_equal_to[0] + is_p2_equal_to[1] + is_p2_equal_to[2] +
						is_p2_equal_to[3] + is_p2_equal_to[4] + is_p2_equal_to[5] +
						is_p2_equal_to[6] + is_p2_equal_to[7] ;
assign	p3_upper_sum = 	is_p3_equal_to[0] + is_p3_equal_to[1] + is_p3_equal_to[2] +
						is_p3_equal_to[3] + is_p3_equal_to[4] + is_p3_equal_to[5] +
						is_p3_equal_to[6] + is_p3_equal_to[7] ;
assign	p4_upper_sum = 	is_p4_equal_to[0] + is_p4_equal_to[1] + is_p4_equal_to[2] +
						is_p4_equal_to[3] + is_p4_equal_to[4] + is_p4_equal_to[5] +
						is_p4_equal_to[6] + is_p4_equal_to[7] ;
assign	p5_upper_sum = 	is_p5_equal_to[0] + is_p5_equal_to[1] + is_p5_equal_to[2] +
						is_p5_equal_to[3] + is_p5_equal_to[4] + is_p5_equal_to[5] +
						is_p5_equal_to[6] + is_p5_equal_to[7] ;
assign	p6_upper_sum = 	is_p6_equal_to[0] + is_p6_equal_to[1] + is_p6_equal_to[2] +
						is_p6_equal_to[3] + is_p6_equal_to[4] + is_p6_equal_to[5] +
						is_p6_equal_to[6] + is_p6_equal_to[7] ;
assign	p7_upper_sum = 	is_p7_equal_to[0] + is_p7_equal_to[1] + is_p7_equal_to[2] +
						is_p7_equal_to[3] + is_p7_equal_to[4] + is_p7_equal_to[5] +
						is_p7_equal_to[6] + is_p7_equal_to[7] ;
assign	p8_upper_sum = 	is_p8_equal_to[0] + is_p8_equal_to[1] + is_p8_equal_to[2] +
						is_p8_equal_to[3] + is_p8_equal_to[4] + is_p8_equal_to[5] +
						is_p8_equal_to[6] + is_p8_equal_to[7] ;
// Find the 4th minimal one
wire	is_p0_5th_minimal;
wire	is_p1_5th_minimal;
wire	is_p2_5th_minimal;
wire	is_p3_5th_minimal;
wire	is_p4_5th_minimal;
wire	is_p5_5th_minimal;
wire	is_p6_5th_minimal;
wire	is_p7_5th_minimal;
wire	is_p8_5th_minimal;

assign	is_p0_5th_minimal = (p0_lower_sum <= 4) && ((p0_lower_sum + p0_upper_sum) >= 4) ? 1 : 0;
assign	is_p1_5th_minimal = (p1_lower_sum <= 4) && ((p1_lower_sum + p1_upper_sum) >= 4) ? 1 : 0;
assign	is_p2_5th_minimal = (p2_lower_sum <= 4) && ((p2_lower_sum + p2_upper_sum) >= 4) ? 1 : 0;
assign	is_p3_5th_minimal = (p3_lower_sum <= 4) && ((p3_lower_sum + p3_upper_sum) >= 4) ? 1 : 0;
assign	is_p4_5th_minimal = (p4_lower_sum <= 4) && ((p4_lower_sum + p4_upper_sum) >= 4) ? 1 : 0;
assign	is_p5_5th_minimal = (p5_lower_sum <= 4) && ((p5_lower_sum + p5_upper_sum) >= 4) ? 1 : 0;
assign	is_p6_5th_minimal = (p6_lower_sum <= 4) && ((p6_lower_sum + p6_upper_sum) >= 4) ? 1 : 0;
assign	is_p7_5th_minimal = (p7_lower_sum <= 4) && ((p7_lower_sum + p7_upper_sum) >= 4) ? 1 : 0;
assign	is_p8_5th_minimal = (p8_lower_sum <= 4) && ((p8_lower_sum + p8_upper_sum) >= 4) ? 1 : 0;

reg [7:0] pixel_out;
always@(*) begin
	pixel_out = 0;
	case(1'b1)
		is_p0_5th_minimal: pixel_out = pixel[0];
		is_p1_5th_minimal: pixel_out = pixel[1];
		is_p2_5th_minimal: pixel_out = pixel[2];
		is_p3_5th_minimal: pixel_out = pixel[3];
		is_p4_5th_minimal: pixel_out = pixel[4];
		is_p5_5th_minimal: pixel_out = pixel[5];
		is_p6_5th_minimal: pixel_out = pixel[6];
		is_p7_5th_minimal: pixel_out = pixel[7];
		is_p8_5th_minimal: pixel_out = pixel[8];
	endcase
end

endmodule