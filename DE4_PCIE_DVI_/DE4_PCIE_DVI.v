`include "DVI/vpg_source/vpg.h"

module DE4_PCIE_DVI(
	input OSC_50_BANK2,
	input OSC_50_BANK3,
	input CPU_RESET_n,
	output [7:0] LED,
	input [3:0] BUTTON,
	input [3:0] SLIDE_SW,
	output FAN_CTRL,
	// PCIe
	input PCIE_PREST_n,
	input PCIE_REFCLK_p,
	input [7:0] PCIE_RX_p,
	input PCIE_SMBCLK,
	inout PCIE_SMBDAT,
	output [7:0] PCIE_TX_p,
	output PCIE_WAKE_n,
	// HSMC-DVI
	output DVI_TX_CLK,
	output [3:1] DVI_TX_CTL,
	output [23:0] DVI_TX_D,
	inout DVI_TX_DDCSCL,
	inout DVI_TX_DDCSDA,
	output DVI_TX_DE,
	output DVI_TX_DKEN,
	output DVI_TX_HS,
	output DVI_TX_HTPLG,
	output DVI_TX_ISEL,
	output DVI_TX_MSEN,
	output DVI_TX_PD_N,
	output DVI_TX_SCL,
	inout DVI_TX_SDA,
	output DVI_TX_VS
);

	assign FAN_CTRL = 1;

	// PCIe x8 interface
	wire pcie_core_clk;
	wire pcie_sc_rd_read;
	wire [11:0] pcie_sc_rd_addr;
	wire [31:0] pcie_sc_rd_data;
 	wire pcie_sc_rd_dval;
	wire pcie_sc_wr_write;
	wire [11:0] pcie_sc_wr_addr;
	wire [31:0] pcie_sc_wr_data;
	wire pcie_dmard_read;
	wire [31:0] pcie_dmard_addr;
	wire [127:0] pcie_dmard_data;
 	wire pcie_dmard_rdvalid;
	wire pcie_dmawr_write;
	wire [31:0] pcie_dmawr_addr;
	wire [127:0] pcie_dmawr_data;
	wire pcie_fifo_mem_sel;

	pcie_example_chaining_pipen1b pcie(
		.iCLK_50(OSC_50_BANK2),
		.free_100MHz(PCIE_REFCLK_p),
 		.local_rstn(1),
 		.pcie_rstn(PCIE_PREST_n),
 		.pipe_mode(0),
 		.pld_clk(pcie_core_clk),
 		.refclk(PCIE_REFCLK_p),
 		.rx_in0(PCIE_RX_p[0]),
 		.rx_in1(PCIE_RX_p[1]),
 		.rx_in2(PCIE_RX_p[2]),
 		.rx_in3(PCIE_RX_p[3]),
 		.rx_in4(PCIE_RX_p[4]),
 		.rx_in5(PCIE_RX_p[5]),
 		.rx_in6(PCIE_RX_p[6]),
 		.rx_in7(PCIE_RX_p[7]),
 		.tx_out0(PCIE_TX_p[0]),
 		.tx_out1(PCIE_TX_p[1]),
 		.tx_out2(PCIE_TX_p[2]),
 		.tx_out3(PCIE_TX_p[3]),
 		.tx_out4(PCIE_TX_p[4]),
 		.tx_out5(PCIE_TX_p[5]),
 		.tx_out6(PCIE_TX_p[6]),
 		.tx_out7(PCIE_TX_p[7]),
 		// I/O transaction (see User Manual 6.2)
 		.core_clk_out(pcie_core_clk),
		.oSC_RD_READ(pcie_sc_rd_read),
		.oSC_RD_ADDR(pcie_sc_rd_addr),  // only 4's multiples can work?
		.iSC_RD_DATA(pcie_sc_rd_data),
 		.iSC_RD_DVAL(pcie_sc_rd_dval),
		.oSC_WR_WRITE(pcie_sc_wr_write),
		.oSC_WR_ADDR(pcie_sc_wr_addr),  // only 4's multiples can work?
		.oSC_WR_DATA(pcie_sc_wr_data),
		.oDMARD_READ(pcie_dmard_read),
		.oDMARD_ADDR(pcie_dmard_addr),  // only 16's multiples can work?
		.iDMARD_DATA(pcie_dmard_data),
		.oDMARD_RDVALID(pcie_dmard_rdvalid),
		.oDMAWR_WRITE(pcie_dmawr_write),
		.oDMAWR_ADDR(pcie_dmawr_addr),  // only 16's multiples can work?
		.oDMAWR_DATA(pcie_dmawr_data),
		.oFIFO_MEM_SEL(pcie_fifo_mem_sel)
	);

	assign PCIE_WAKE_n = 0;

	// RAM for PCIe single cycle r/w
	wire ram1_wren;
	wire [9:0] ram1_wraddress;
	wire [31:0] ram1_data;
	wire ram1_rden;
	wire [9:0] ram1_rdaddress;
	wire [31:0] ram1_q;
	reg ram1_rden_d1;
	reg ram1_rden_d2;

	ram_4k ram1(
		.aclr(~CPU_RESET_n),
		.clock(pcie_core_clk),
		.data(ram1_data),
		.rdaddress(ram1_rdaddress),
		.rden(ram1_rden),
		.wraddress(ram1_wraddress),
		.wren(ram1_wren),
		.q(ram1_q)
	);

	assign ram1_wren = pcie_sc_wr_write;
	assign ram1_wraddress = pcie_sc_wr_addr[11:2];
	assign ram1_data = pcie_sc_wr_data;
	assign ram1_rden = pcie_sc_rd_read;
	assign ram1_rdaddress = pcie_sc_rd_addr[11:2];
	assign pcie_sc_rd_data = ram1_q;
	assign pcie_sc_rd_dval = ram1_rden_d2;

	always @(posedge pcie_core_clk) begin
		ram1_rden_d1 <= ram1_rden;
		ram1_rden_d2 <= ram1_rden_d1;
	end

	// RAM for PCIe DMA r/w
	wire ram2_wren;
	wire [9:0] ram2_wraddress;
	wire [127:0] ram2_data;
	wire ram2_rden;
	wire [9:0] ram2_rdaddress;
	wire [127:0] ram2_q;

	ram_16k ram2(
		.aclr(~CPU_RESET_n),
		.clock(pcie_core_clk),
		.data(ram2_data),
		.rdaddress(ram2_rdaddress),
		.rden(ram2_rden),
		.wraddress(ram2_wraddress),
		.wren(ram2_wren),
		.q(ram2_q)
	);

	assign ram2_wren = pcie_dmawr_write;
	assign ram2_wraddress = pcie_dmawr_addr[13:4];
	assign ram2_data = pcie_dmawr_data;
	assign ram2_rden = pcie_dmard_read;
	assign ram2_rdaddress = pcie_dmard_addr[13:4];
	assign pcie_dmard_data = ram2_q;

	// Input Vertex Buffer
	wire	ivb_write;
	wire	ivb_wleft;//*needs check
	wire	[127:0]	ivb_wdata;
	wire	ivb_rvalid;
	wire	[255:0]	ivb_rdata;
	
	IVB IVB_inst(
		.clk(pcie_core_clk),
		.reset(CPU_RESET_n),
		.wen(ivb_write),
		.wleft(ivb_wleft),
		.wdata(ivb_wdata),
		//buffer interface
		.rvalid(ivb_rvalid),
		.rdata(ivb_rdata)
	)
	
	assign	ivb_write	= pcie_dmawr_write;
	assign	ivb_wleft	= pcie_dmawr_addr[4];
	assign	ivb_wdata	= pcie_dmawr_data;
	
	//debug
	assign	LED[4] = ivb_write;
	assign	LED[5] = ivb_wleft;
	assign	LED[6] = ivb_valid;
	
	// PLL for DVI
	wire reset_n;
	wire pll_100M;
	wire pll_100K;

	sys_pll sys_pll_inst(
		.areset(0),
		.inclk0(OSC_50_BANK3),
		.c0(pll_100M),
		.c1(pll_100K),
		.locked(reset_n)
	);

	// DVI mode
	wire [3:0] vpg_mode;
	reg [3:0] vpg_mode_d1;
	reg vpg_mode_change;

	assign vpg_mode = SLIDE_SW[3:0];

	always @(posedge pll_100M or negedge reset_n) begin
		if (!reset_n) begin
			vpg_mode_d1 <= 0;
			vpg_mode_change <= 1;
		end else begin
			vpg_mode_d1 <= vpg_mode;
			vpg_mode_change <= (vpg_mode != vpg_mode_d1);
		end
	end

	// video pattern generator
	wire vpg_pclk;
	wire vpg_de;
	wire vpg_hs;
	wire vpg_vs;
	wire [23:0] vpg_data;
	wire [11:0] vpg_x;
	wire [11:0] vpg_y;

	vpg vpg_inst(
		.clk_100(pll_100M),
		.reset_n(reset_n),
		.mode(vpg_mode),
		.mode_change(vpg_mode_change),
		.disp_color(`COLOR_RGB444),
		.vpg_pclk(vpg_pclk),
		.vpg_de(vpg_de),
		.vpg_hs(vpg_hs),
		.vpg_vs(vpg_vs),
		.vpg_r(vpg_data[23:16]),
		.vpg_g(vpg_data[15:8]),
		.vpg_b(vpg_data[7:0]),
		.vpg_x(vpg_x),
		.vpg_y(vpg_y)
	);

	// DVI transmittion
	assign DVI_TX_ISEL = 0;
	assign DVI_TX_SCL = 1;
	assign DVI_TX_HTPLG = 1;
	assign DVI_TX_SDA = 1;
	assign DVI_TX_PD_N = 1;
	assign DVI_TX_CLK = vpg_pclk;
	assign DVI_TX_DE = vpg_de;
	assign DVI_TX_VS = vpg_vs;
	assign DVI_TX_HS = vpg_hs;
	assign DVI_TX_D = vpg_data;

	// LED
	assign LED[3:0] = vpg_mode;

endmodule
