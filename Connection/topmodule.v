`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:15:56 09/20/2016 
// Design Name: 
// Module Name:    topmodule 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module topmodule(
  input reset,
  input signal_detect,
  output mgt_rx_reset,
  output mgt_tx_reset,
  input userclk,
  input userclk2,
  input dcm_locked,
  input [1 : 0] rxbufstatus,
  input [0 : 0] rxchariscomma,
  input [0 : 0] rxcharisk,
  input [2 : 0] rxclkcorcnt,
  input [7 : 0] rxdata,
  input [0 : 0] rxdisperr,
  input [0 : 0] rxnotintable,
  input [0 : 0] rxrundisp,
  input txbuferr,
  output powerdown,
  output txchardispmode,
  output txchardispval,
  output txcharisk,
  output [7 : 0] txdata,
  output enablealign,
  input [7 : 0] gmii_txd,
  input gmii_tx_en,
  input gmii_tx_er,
  output [7 : 0] gmii_rxd,
  output gmii_rx_dv,
  output gmii_rx_er,
  output gmii_isolate,
  input [4 : 0] configuration_vector,
  output [15 : 0] status_vector
    );
	 
Ethernet eth0 (
  .reset(reset), // input reset
  .signal_detect(signal_detect), // input signal_detect
  .mgt_rx_reset(mgt_rx_reset), // output mgt_rx_reset
  .mgt_tx_reset(mgt_tx_reset), // output mgt_tx_reset
  .userclk(userclk), // input userclk
  .userclk2(userclk2), // input userclk2
  .dcm_locked(dcm_locked), // input dcm_locked
  .rxbufstatus(rxbufstatus), // input [1 : 0] rxbufstatus
  .rxchariscomma(rxchariscomma), // input [0 : 0] rxchariscomma
  .rxcharisk(rxcharisk), // input [0 : 0] rxcharisk
  .rxclkcorcnt(rxclkcorcnt), // input [2 : 0] rxclkcorcnt
  .rxdata(rxdata), // input [7 : 0] rxdata
  .rxdisperr(rxdisperr), // input [0 : 0] rxdisperr
  .rxnotintable(rxnotintable), // input [0 : 0] rxnotintable
  .rxrundisp(rxrundisp), // input [0 : 0] rxrundisp
  .txbuferr(txbuferr), // input txbuferr
  .powerdown(powerdown), // output powerdown
  .txchardispmode(txchardispmode), // output txchardispmode
  .txchardispval(txchardispval), // output txchardispval
  .txcharisk(txcharisk), // output txcharisk
  .txdata(txdata), // output [7 : 0] txdata
  .enablealign(enablealign), // output enablealign
  .gmii_txd(gmii_txd), // input [7 : 0] gmii_txd
  .gmii_tx_en(gmii_tx_en), // input gmii_tx_en
  .gmii_tx_er(gmii_tx_er), // input gmii_tx_er
  .gmii_rxd(gmii_rxd), // output [7 : 0] gmii_rxd
  .gmii_rx_dv(gmii_rx_dv), // output gmii_rx_dv
  .gmii_rx_er(gmii_rx_er), // output gmii_rx_er
  .gmii_isolate(gmii_isolate), // output gmii_isolate
  .configuration_vector(configuration_vector), // input [4 : 0] configuration_vector
  .status_vector(status_vector) // output [15 : 0] status_vector
);

endmodule
