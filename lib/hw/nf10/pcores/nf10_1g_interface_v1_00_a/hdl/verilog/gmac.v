///////////////////////////////////////////////////////////////////////////////
// $Id: gmac.v 3000 2009-11-21 09:09:56Z hyzeng $
//
// Module: gmac.v
// Project: NetFPGA 10G
// Description: GMAC wrapper
//
///////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module gmac
#(
  parameter PORT_NUMBER   = 0
 )
  (
   // EMAC0 Clocking
   // 125MHz clock output from transceiver
   output clk125,

   input  RESET,

    // 1000BASE-X PCS/PMA Interface - EMAC0
    output          TXP_0,
    output          TXN_0,
    input           RXP_0,
    input           RXN_0,
    input           [4:0] PHYAD_0,
    output          RESETDONE_0,
    
    // 1000BASE-X PCS/PMA Interface - EMAC1
    output          TXP_1,
    output          TXN_1,
    input           RXP_1,
    input           RXN_1,
    input           [4:0] PHYAD_1,
    output          RESETDONE_1,

    // 1000BASE-X PCS/PMA MGT Clock buffer inputs 
    input			gtxclk_0,
    input			gtxclk_1,
    input           GTRESET, 

   //Local Link Interface
   input  [7 : 0]  tx_data_0,
   input  	   	   tx_data_valid_0,
   output          tx_ack_0,
 
   output [7 : 0]  rx_data_0,
   output 	   	   rx_data_valid_0,
   output          rx_good_frame_0,
   output          rx_bad_frame_0,
   
   //Local Link Interface
   input  [7 : 0]  tx_data_1,
   input  	   	   tx_data_valid_1,
   output          tx_ack_1,
 
   output [7 : 0]  rx_data_1,
   output 	   	   rx_data_valid_1,
   output          rx_good_frame_1,
   output          rx_bad_frame_1
  );

    
    // Transceiver output clock (REFCLKOUT at 125MHz)
    wire            clk125_o;
    wire            clk125_dcm;
    // 125MHz clock input to wrappers
    wire            clk62_5;
    wire            clk62_5_pre_bufg;
    wire            clk125_fb, clk125_fb_bufg;

    // 125MHz from DCM is routed through a BUFG and 
    // input to the MAC wrappers.
    // This clock can be shared between multiple MAC instances.
    BUFG bufg_clk125 (.I(clk125_o), .O(clk125_dcm));// GTX-PLL-DCM
    BUFG bufg_clk125_fb (.I(clk125_fb), .O(clk125));

    // Divide 125MHz reference clock down by 2 to get
    // 62.5MHz clock for 2 byte GTX internal datapath.
    DCM_BASE clk62_5_dcm
    (
    .CLKIN(clk125_dcm),
    .CLK0(clk125_fb),
    .CLK180(),
    .CLK270(),
    .CLK2X(),
    .CLK2X180(),
    .CLK90(),
    .CLKDV(clk62_5_pre_bufg),
    .CLKFX(),
    .CLKFX180(),
    .LOCKED(),
    .CLKFB(clk125),
    .RST(RESET));

    BUFG clk62_5_bufg (.I(clk62_5_pre_bufg), .O(clk62_5));

    mac_block v5_emac_block_inst
    (
    // EMAC0 Clocking
    // 125MHz clock output from transceiver
    .CLK125_OUT                          (clk125_o),
    // 125MHz clock input from BUFG
    .CLK125                              (clk125),
    .CLK62_5							 (clk62_5),
    
    // 1000BASE-X PCS/PMA Interface - EMAC1
    .TXP_0                               (TXP_0),
    .TXN_0                               (TXN_0),
    .RXP_0                               (RXP_0),
    .RXN_0                               (RXN_0),
    .PHYAD_0                             (PHYAD_0),
    .RESETDONE_0                         (RESETDONE_0),

    // Client Receiver Interface - EMAC0
    .EMAC0CLIENTRXD                      (rx_data_0),
    .EMAC0CLIENTRXDVLD                   (rx_data_valid_0),
    .EMAC0CLIENTRXGOODFRAME              (rx_good_frame_0),
    .EMAC0CLIENTRXBADFRAME               (rx_bad_frame_0),
    .EMAC0CLIENTRXFRAMEDROP              (),
    .EMAC0CLIENTRXSTATS                  (),
    .EMAC0CLIENTRXSTATSVLD               (),
    .EMAC0CLIENTRXSTATSBYTEVLD           (),

    // Client Transmitter Interface - EMAC0
    .CLIENTEMAC0TXD                      (tx_data_0),
    .CLIENTEMAC0TXDVLD                   (tx_data_valid_0),
    .EMAC0CLIENTTXACK                    (tx_ack_0),
    .CLIENTEMAC0TXFIRSTBYTE              (1'b0),
    .CLIENTEMAC0TXUNDERRUN               (1'b0),
    .EMAC0CLIENTTXCOLLISION              (),
    .EMAC0CLIENTTXRETRANSMIT             (),
    .CLIENTEMAC0TXIFGDELAY               (8'b0),
    .EMAC0CLIENTTXSTATS                  (),
    .EMAC0CLIENTTXSTATSVLD               (),
    .EMAC0CLIENTTXSTATSBYTEVLD           (),

    // MAC Control Interface - EMAC0
    .CLIENTEMAC0PAUSEREQ                 (1'b0),
    .CLIENTEMAC0PAUSEVAL                 (16'h0),

    //EMAC-MGT link status
    .EMAC0CLIENTSYNCACQSTATUS            (),
    .EMAC0ANINTERRUPT                    (),


    // 1000BASE-X PCS/PMA Interface - EMAC1
    .TXP_1                               (TXP_1),
    .TXN_1                               (TXN_1),
    .RXP_1                               (RXP_1),
    .RXN_1                               (RXN_1),
    .PHYAD_1                             (PHYAD_1),
    .RESETDONE_1                         (RESETDONE_1),
    
    // Client Receiver Interface - EMAC1
    .EMAC1CLIENTRXD                      (rx_data_1),
    .EMAC1CLIENTRXDVLD                   (rx_data_valid_1),
    .EMAC1CLIENTRXGOODFRAME              (rx_good_frame_1),
    .EMAC1CLIENTRXBADFRAME               (rx_bad_frame_1),
    .EMAC1CLIENTRXFRAMEDROP              (),
    .EMAC1CLIENTRXSTATS                  (),
    .EMAC1CLIENTRXSTATSVLD               (),
    .EMAC1CLIENTRXSTATSBYTEVLD           (),

    // Client Transmitter Interface - EMAC0
    .CLIENTEMAC1TXD                      (tx_data_1),
    .CLIENTEMAC1TXDVLD                   (tx_data_valid_1),
    .EMAC1CLIENTTXACK                    (tx_ack_1),
    .CLIENTEMAC1TXFIRSTBYTE              (1'b0),
    .CLIENTEMAC1TXUNDERRUN               (1'b0),
    .EMAC1CLIENTTXCOLLISION              (),
    .EMAC1CLIENTTXRETRANSMIT             (),
    .CLIENTEMAC1TXIFGDELAY               (8'b0),
    .EMAC1CLIENTTXSTATS                  (),
    .EMAC1CLIENTTXSTATSVLD               (),
    .EMAC1CLIENTTXSTATSBYTEVLD           (),

    // MAC Control Interface - EMAC1
    .CLIENTEMAC1PAUSEREQ                 (1'b0),
    .CLIENTEMAC1PAUSEVAL                 (16'h0),

    //EMAC-MGT link status
    .EMAC1CLIENTSYNCACQSTATUS            (),
    .EMAC1ANINTERRUPT                    (),

    // 1000BASE-X PCS/PMA MGT Clock buffer inputs 
    .CLK_DS_0                            (gtxclk_0), 
    .CLK_DS_1                            (gtxclk_1), 
    .GTRESET                             (GTRESET), 

    // Asynchronous Reset Input
    .RESET                               (RESET));

 endmodule