// /**
//  * This Verilog HDL file is used for simulation and synthesis in
//  * the chaining DMA design example. It arbitrates PCI Express packets for
//  * the modules altpcierd_dma_dt (read or write) and altpcierd_rc_slave. It
//  * instantiates the Endpoint memory used for the DMA read and write transfer.
//  */
// synthesis translate_off
`timescale 1ns / 1ps
// synthesis translate_on

// synthesis verilog_input_version verilog_2001
// turn off superfluous verilog processor warnings
// altera message_level Level1
// altera message_off 10034 10035 10036 10037 10230 10240 10030

//-----------------------------------------------------------------------------
// Title         : PCI Express Reference Design Example Application
// Project       : PCI Express MegaCore function
//-----------------------------------------------------------------------------
// File          : altpcierd_cdma_app_icm.v
// Author        : Altera Corporation
//-----------------------------------------------------------------------------
// Description :
// This is the complete example application for the PCI Express Reference
// Design. This has all of the application logic for the example.
//-----------------------------------------------------------------------------
// Copyright (c) 2008 Altera Corporation. All rights reserved.  Altera products are
// protected under numerous U.S. and foreign patents, maskwork rights, copyrights and
// other intellectual property laws.
//
// This reference design file, and your use thereof, is subject to and governed by
// the terms and conditions of the applicable Altera Reference Design License Agreement.
// By using this reference design file, you indicate your acceptance of such terms and
// conditions between you and Altera Corporation.  In the event that you do not agree with
// such terms and conditions, you may not use the reference design file. Please promptly
// destroy any copies you have made.
//
// This reference design file being provided on an "as-is" basis and as an accommodation
// and therefore all warranties, representations or guarantees of any kind
// (whether express, implied or statutory) including, without limitation, warranties of
// merchantability, non-infringement, or fitness for a particular purpose, are
// specifically disclaimed.  By making this reference design file available, Altera
// expressly does not recommend, suggest or require that this reference design file be
// used in combination with any other product not provided by Altera.
//-----------------------------------------------------------------------------
//
// TLP Packet constant
`define TLP_FMT_4DW_W        2'b11    // TLP FMT field  -> 64 bits Write
`define TLP_FMT_3DW_W        2'b10    // TLP FMT field  -> 32 bits Write
`define TLP_FMT_4DW_R        2'b01    // TLP FMT field  -> 64 bits Read
`define TLP_FMT_3DW_R        2'b00    // TLP FMT field  -> 32 bits Read

`define TLP_FMT_CPL          2'b00    // TLP FMT field  -> Completion w/o data
`define TLP_FMT_CPLD         2'b10    // TLP FMT field  -> Completion with data

`define TLP_TYPE_WRITE       5'b00000 // TLP Type field -> write
`define TLP_TYPE_READ        5'b00000 // TLP Type field -> read
`define TLP_TYPE_READ_LOCKED 5'b00001 // TLP Type field -> read_lock
`define TLP_TYPE_CPLD        5'b01010 // TLP Type field -> Completion with data
`define TLP_TYPE_IO          5'b00010 // TLP Type field -> IO

`define TLP_TC_DEFAULT       3'b000   // Default TC of the TLP
`define TLP_TD_DEFAULT       1'b0     // Default TD of the TLP
`define TLP_EP_DEFAULT       1'b0     // Default EP of the TLP
`define TLP_ATTR_DEFAULT     2'b0     // Default EP of the TLP

`define RESERVED_1BIT        1'b0     // reserved bit on 1 bit
`define RESERVED_2BIT        2'b00    // reserved bit on 1 bit
`define RESERVED_3BIT        3'b000   // reserved bit on 1 bit
`define RESERVED_4BIT        4'b0000  // reserved bit on 1 bit

`define EP_ADDR_READ_OFFSET  16
`define TRANSACTION_ID       3'b000

`define ZERO_QWORD           64'h0000_0000_0000_0000
`define ZERO_DWORD           32'h0000_0000
`define ZERO_WORD            16'h0000
`define ZERO_BYTE            8'h00

`define ONE_QWORD            64'h0000_0000_0000_0001
`define ONE_DWORD            32'h0000_0001
`define ONE_WORD             16'h0001
`define ONE_BYTE             8'h01

`define MINUS_ONE_QWORD      64'hFFFF_FFFF_FFFF_FFFF
`define MINUS_ONE_DWORD      32'hFFFF_FFFF
`define MINUS_ONE_WORD       16'hFFFF
`define MINUS_ONE_BYTE       8'hFF

`define DIRECTION_WRITE      1
`define DIRECTION_READ       0


module altpcierd_cdma_app_icm #(
   parameter MAX_NUMTAG             = 32,
   parameter AVALON_WADDR           = 12,
   parameter CHECK_BUS_MASTER_ENA   = 0,
   parameter AVALON_WDATA           = 64,
   parameter MAX_PAYLOAD_SIZE_BYTE  = 256,
   parameter BOARD_DEMO             = 0,
   parameter TL_SELECTION           = 0,
   parameter TXCRED_WIDTH           = 36,
   parameter CLK_250_APP            = 0,  // When 1 indicate application clock rate is 250MHz instead of 125 MHz
   parameter RC_64BITS_ADDR         = 0,  // When 1 use 64 bit tx_desc address and not 32
   parameter USE_CREDIT_CTRL        = 0,
   parameter USE_MSI                = 1,  // When 1, tx_arbitration uses tx_cred
   parameter USE_DMAWRITE           = 1,
   parameter USE_DMAREAD            = 1,
   parameter AVALON_ST_128          = 0,
   parameter INTENDED_DEVICE_FAMILY = "Cyclone IV GX",
   parameter CDMA_AST_RXWS_LATENCY  = 2,
	  parameter AVALON_BYTE_WIDTH = AVALON_WDATA/8
   )(
   input clk_in  ,
   input rstn    ,

   input[12:0] cfg_busdev,
   input[31:0] cfg_devcsr,
   input[31:0] cfg_prmcsr,
   input[23:0] cfg_tcvcmap,
   input[31:0] cfg_linkcsr,
   input[15:0] cfg_msicsr,
   input[19:0] ko_cpl_spc_vc0,

   output reg  cpl_pending,
   output[6:0] cpl_err,
   output [127:0] err_desc,

   // MSI signals section
   input       app_msi_ack,
   output      app_msi_req,
   output[2:0] app_msi_tc ,
   output[4:0] app_msi_num,

   // Legacy Interupt signals
   output      app_int_sts,
   input       app_int_ack,

   // Receive section channel 0
   output       rx_ack0  ,
   output       rx_mask0 ,
   output       rx_ws0   ,
   input        rx_req0  ,
   input[135:0] rx_desc0 ,
   input[127:0] rx_data0 ,
   input[15:0]  rx_be0,
   input        rx_dv0   ,
   input        rx_dfr0  ,
   input [15:0] rx_ecrc_bad_cnt,

   //transmit section channel 0
   output                   tx_req0 ,
   input                    tx_ack0 ,
   output [127:0]           tx_desc0,
   output                   tx_dv0  ,
   output                   tx_dfr0 ,
   input                    tx_ws0 ,
   output[127:0]            tx_data0,
   output                   tx_err0 ,
   input                    tx_mask0,
   input                    cpld_rx_buffer_ready,
   input [TXCRED_WIDTH-1:0] tx_cred0,
   input [15:0]             rx_buffer_cpl_max_dw,  // specifify the maximum amount of data available in RX Buffer for a given MRd
   input                    tx_stream_ready0,
	
	input        			sc_rd_dval,
	output 	[63:0]      sc_rd_addr,
	input 	[31:0]      sc_rd_data,
	output          		sc_rd_read,

	output 	[63:0]      sc_wr_addr,
	output 	[31:0]      sc_wr_data,
	output					sc_wr_write,
   
   output	oDMARD_FRAME,
	output	[31:0]oDMARD_ADDR,
	output	oDMARD_READ,
	output	oDMARD_RDVALID,
	input		[127:0]iDMARD_DATA,
	
	output	oDMAWR_WRITE,
	output	[31:0]oDMAWR_ADDR,
	output	[127:0]oDMAWR_DATA,
	output	[ 15:0]oDMAWR_BE,
   
   output	oUSER_INT_ACK,
   
   output	oFIFO_MEM_SEL,
   
   output	int_clr,
   input		[13:0]  test_usedw,
   
   input		iCLK_50,

	input                          usmem_rd_data_valid,
   output [AVALON_WADDR-1:0]      usmem_rd_addr ,
   input [AVALON_WDATA-1:0]       usmem_rd_data  ,
   output [AVALON_WADDR-1:0]      usmem_wr_addr ,
   output [AVALON_WDATA-1:0]      usmem_wr_data ,
   output                         ussel_epmem       ,
   output								 us_mem_write,
   output [AVALON_BYTE_WIDTH-1:0] usmem_wr_be,
   output          mem_wr_ena,  
   output          mem_rd_ena

   );


ALT_PCIe_RX_Interface U0 (

					.iCLK(clk_in),
					.iRST_n(rstn),
					
					.iRX_BE(rx_be0),
					.iRX_DATA(rx_data0),
					.iRX_DESC(rx_desc0),
					.iRX_DRF(rx_dfr0),
					.iRX_DV(rx_dv0),
					.iRX_REQ(rx_req0),
					.oRX_ACK(rx_ack0),
					.oRX_MASK(rx_mask0),
					.oRX_WS(rx_ws0),
					
	

					
					.oSC_WR_ADDR(sc_wr_addr),
					.oSC_WR_DATA(sc_wr_data),
					.oSC_WR_WRITE(sc_wr_write),
					
					.oSC_RD_ADDR(sc_rd_addr),
					.oSC_RD_READ(sc_rd_read),
					.iSC_RD_DATA(sc_rd_data),
					.iSC_RD_VALID(sc_rd_dval),


					.oTLP_REQID(tlp_reqid),
					.oTLP_LENGTH(tlp_length),
					.oTLP_TAG(tlp_tag),
					.oTLP_ATTR(tlp_attr),
					.oTLP_LOWADDR(tlp_lowaddr),
					.oTLP_TC(tlp_tc),
					
					.oMRD_CPL_REQ(),
					
					.oST_DMA(st_dma),
					.oST_DMA_DELAY(),
					.iDMA_DONE(dma_done),
					
					.oCPL_USER_REGISTER(cpl_user_register),
					.oRD_USER_REGISTER(rd_user_register),			//read signal
					
					.oCPL_DMA_REGISTER(cpl_dma_register),
					.oRD_DMA_REGISTER(rd_dma_register),				//read signal
					
					.oReg_DMAddr(Reg_DMAddr),
					.oReg_DMABytCnt(Reg_DMABytCnt),
					.oReg_DMALocAddr(Reg_DMALocAddr),	
					.oReg_DMACntr(Reg_DMACntr),
					
					.oAPP_INT_STS(),
					.oAPP_MSI_NUM(),
					.oAPP_MSI_TC(),
					.CPL_ERR(),
					.CPL_PENDING(),
					
					.oSET_FREE(set_free),
					.oTAG_IN(tag_in),
					.oSET_TAG_DCNT(set_tag_dcnt),
					
					.oDMA_DONE(idma_done),
					.iCFG_BUSDEV(cfg_busdev),
					
					.oDMAWR_WRITE_ALGI(oDMAWR_WRITE),
					.oDMAWR_ADDR_ALGI(oDMAWR_ADDR),
					.oDMAWR_DATA_ALGI(oDMAWR_DATA),
					.oDMAWR_BE_ALGI(oDMAWR_BE),	
					
					.oUSER_INT_ACK(oUSER_INT_ACK),
					.int_clr(int_clr),
					
					.iCLK_50(iCLK_50),
					
					.oFIFO_MEM_SEL(oFIFO_MEM_SEL)


						);



wire	set_free;
wire	[31:0]tag_in;

wire	[15:0]tlp_reqid;
wire	[ 9:0]tlp_length;
wire	[ 7:0]tlp_tag;
wire	[ 1:0]tlp_attr;
wire	[ 6:0]tlp_lowaddr;
wire	[ 2:0]tlp_tc;

wire	[31:0]cpl_user_register;
wire	rd_user_register;			


wire	[31:0]cpl_dma_register;
wire	rd_dma_register;

wire	st_dma;
wire	dma_done;

wire	[31:0]Reg_DMAddr;
wire	[31:0]Reg_DMABytCnt;
wire	[31:0]Reg_DMALocAddr;
wire	[31:0]Reg_DMACntr;

wire	valid;
wire	get;
wire	[31:0]tag_out;

TAG_STORAGE U2(


					.iCLK(clk_in),
					.iRST_n(rstn),

					.iSET_FREE(set_free),
					.iTAG_IN(tag_in),
					
					.oVALID(valid),
					.iGET(get),
					.oTAG_OUT(tag_out),
					.iTAG_DCNT(tag_dcnt),
					.iSET_TAG_DCNT(set_tag_dcnt)

					);

wire	[15:0]set_tag_dcnt;

	reg	[4:0]st_dma_delay;
	always@(posedge clk_in)
		begin
			st_dma_delay[0] <= st_dma;
			st_dma_delay[1] <= st_dma_delay[0];
			st_dma_delay[2] <= st_dma_delay[1];
			st_dma_delay[3] <= st_dma_delay[2];
			st_dma_delay[4] <= st_dma_delay[3];
		end




ALT_PCIe_TX_Interface U1 (


						.iCLK(clk_in),
						.iRST_n(rstn),
						
						.oTX_DATA(tx_data0),
						.oTX_DESC(tx_desc0),
						.oTX_DFR(tx_dfr0),
						.oTX_DV(tx_dv0),
						.oTX_ERR(tx_err0),
						.oTX_REQ(tx_req0),
						.iTX_ACK(tx_ack0),
						.iTX_WS(tx_ws0),
						.iTX_MASK(tx_mask0),


						.iTLP_REQID(tlp_reqid),
						.iTLP_LENGTH(tlp_length),
						.iTLP_TAG(tlp_tag),
						.iTLP_ATTR(tlp_attr),
						.iTLP_LOWADDR(tlp_lowaddr),
						.iTLP_TC(tlp_tc),
						.iCFG_BUSDEV(cfg_busdev),
						

						.iCPL_USER_REGISTER(cpl_user_register),
						.iRD_USER_REGISTER(rd_user_register),			//read signal
					
						.iCPL_DMA_REGISTER(cpl_dma_register),
						.iRD_DMA_REGISTER(rd_dma_register),				//read signal


						.iST_DMA(st_dma_delay[4]),
						.iST_DMA_ORI(st_dma),
						
						.oDMA_DONE(dma_done),

						.iReg_DMAddr(Reg_DMAddr),
						.iReg_DMABytCnt(Reg_DMABytCnt),
						.iReg_DMALocAddr(Reg_DMALocAddr),
						.iReg_DMACntr(Reg_DMACntr),

						.oDMARD_FRAME(oDMARD_FRAME),
						.oDMARD_ADDR(oDMARD_ADDR),
						.oDMARD_READ(oDMARD_READ),
						.oDMARD_RDVALID(oDMARD_RDVALID),
						.iDMARD_DATA(iDMARD_DATA),	

						
						.iVALID(valid),
						.oGET(get),
						.iTAG_OUT(tag_out),
						.oTAG_DCNT(tag_dcnt),
						.iDMA_DONE(idma_done),
						
						.test_usedw(test_usedw)
						

						);


wire	idma_done;
wire	[15:0]tag_dcnt;

endmodule
