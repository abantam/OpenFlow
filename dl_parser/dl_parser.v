`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:53:37 09/10/2016 
// Design Name: 
// Module Name:    dl_parser 
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
module dl_parser
#(
	//AXI Stream Data Width
	parameter C_AXIS_DATA_WIDTH=64,
	parameter C_AXIS_LEN_DATA_WIDTH=16,
	parameter C_AXIS_SPT_DATA_WIDTH=8	
)
(
	//Global ports
	input asclk,
	input aresetn,
	
	input [C_AXIS_DATA_WIDTH-1:0] tx_data,
	input [(C_AXIS_DATA_WIDTH/8)-1:0] tx_strb,
	input tx_valid,
	input tx_last,
	input [C_AXIS_LEN_DATA_WIDTH-1:0] tx_len_data,
	input [C_AXIS_SPT_DATA_WIDTH-1:0] tx_spt_data,
	input fifo_empty,
	output reg fifo_rd_en,
	output reg tx_user_rd_en,
	
	//Lu_entry_composer
	output reg dl_start,
	
	output reg dl_done,
	output reg [C_AXIS_LEN_DATA_WIDTH-1:0] pkt_len,
	output reg [C_AXIS_SPT_DATA_WIDTH-1:0] src_port,
	output reg [47:0] dl_dst,
	output reg [47:0] dl_src,
	output reg [15:0] dl_ethtype,
	output reg [15:0] dl_vlantag,
	
	output reg arp_done,
	output reg [7:0] arp_op,
	output reg [31:0] arp_ip_src,
	output reg [31:0] arp_ip_dst,
	
	output reg ip_tp_done,
	output reg [5:0] ip_tos,
	output reg [7:0] ip_proto,
	output reg [31:0] ip_src,
	output reg [31:0] ip_dst,
	
	input compose_done,
	
	//Registers
	output reg [31:0] dl_parse_cnt,
	output reg [31:0] arp_parse_cnt,
	output reg [31:0] ip_tp_parse_cnt
);

	//--------------------Internal parameters--------------------

	//Data read State Machine
	localparam NUM_DT_RD_STATES=3;
	localparam DT_RD_1ST=1,
				  DT_RD_REST=2,
				  DT_RD_WAIT=4;
	
	//DL State Machine
	localparam NUM_DL_STATES=9;
	localparam DL_WAIT_TVALID=1,
				  DL_PARSE_2ND=2,
				  DL_PARSE_MORE=4,
				  DL_SFT16_1ST=8,
				  DL_SFT16_MORE=16,
				  DL_SFT16_LAST=32,
				  DL_SFT48_1ST=64,
				  DL_SFT48_MORE=128,
				  DL_SFT48_LAST=256;
	
	//ARP State Machine
	localparam NUM_MPLS_STATES = 2;
	localparam MPLS_WAIT_START = 1,
				  MPLS_WAIT_DONE = 2;
				  
	//IP_TP_and_above State Machine
	localparam NUM_IP_TP_STATES = 5;
	localparam IP_TP_WAIT_START = 1,
				  IP_TP_PARSE_2ND = 2,
				  IP_TP_PARSE_3RD = 4,
				  IP_TP_PARSE_MORE = 8,
				  IP_TP_WAIT_DONE = 16;
				  
	//--------------------Wires/Regs--------------------
	
	//Endian Conversion
	wire [C_AXIS_DATA_WIDTH-1:0] be_tx_data_infifo;
	reg [C_AXIS_DATA_WIDTH-1:0] be_tx_data;
	wire [(C_AXIS_DATA_WIDTH/8)-1:0] be_tx_strb_infifo;
	reg [(C_AXIS_DATA_WIDTH/8)-1:0] be_tx_strb;
	
	reg [C_AXIS_LEN_DATA_WIDTH-1:0] tx_len_data_int;
	reg [C_AXIS_SPT_DATA_WIDTH-1:0] tx_spt_data_int;
	
   //Data read State machine
	reg [NUM_DT_RD_STATES-1:0] dt_rd_state, dt_rd_state_nxt;
	reg tx_valid_int, tx_valid_int_nxt;
	reg tx_last_int, tx_last_int_nxt;
	reg vlan_msb, vlan_lsb;
	wire vlan_msb_nxt, vlan_lsb_nxt;
	
	//DL State Machine
	reg dl_start_nxt;
	reg [C_AXIS_LEN_DATA_WIDTH-1:0] pkt_len_nxt;
	reg [C_AXIS_SPT_DATA_WIDTH-1:0] src_port_nxt;
	reg [47:0] dl_dst_nxt;
	reg [47:0] dl_src_nxt;
	reg [15:0] dl_ethtype_nxt;
	reg [15:0] dl_vlantag_nxt;
	reg [C_AXIS_DATA_WIDTH-1:0] dl_tdata, dl_tdata_nxt;
	reg [15:0] dl_tdata16_buf, dl_tdata16_buf_nxt;
	reg [47:0] dl_tdata48_buf, dl_tdata48_buf_nxt;
	reg dl_done_nxt;
	reg ip_start, ip_start_nxt;
	reg arp_start, arp_start_nxt;
	reg dl_valid, dl_valid_nxt;
	reg [NUM_DL_STATES-1:0] dl_state, dl_state_nxt;
	
	//Data Reading
	always @* begin
		fifo_rd_en = 0;
		tx_user_rd_en = 0;
		tx_valid_int_nxt = 0;
		tx_last_int_nxt = 0;
		dt_rd_state_nxt = dt_rd_state;
		case(dt_rd_state)
			DT_RD_1ST: begin
				if(~fifo_empty) begin
					fifo_rd_en = 1;
					tx_user_rd_en = 1;
					tx_valid_int_nxt = tx_valid;
					dt_rd_state_nxt = DT_RD_REST;
				end
			end
			DT_RD_REST: begin
				if(~fifo_empty) begin
					fifo_rd_en = 1;
					tx_valid_int_nxt = tx_valid;
					tx_last_int_nxt = tx_last;
					if(tx_last) begin
						dt_rd_state_nxt = DT_RD_WAIT;
					end
				end
			end
			DT_RD_WAIT: begin
				dt_rd_state_nxt = DT_RD_1ST;
			end
		endcase
	end
	
	always @(posedge asclk) begin
		if(~aresetn) begin
			tx_valid_int <= 0;
			tx_last_int <= 0;
			dt_rd_state <= DT_RD_1ST;
		end
		else begin
			tx_valid_int <= tx_valid_int_nxt;
			tx_last_int <= tx_last_int_nxt;
			dt_rd_state <= dt_rd_state_nxt;
		end
	end
	
	//assign vlan_msb_nxt = ((be_tx_data_infifo[63:48] == `TYPE_VLAN) || (be_tx_data_infifo[63:48] == `TYPE_VLAN_QINQ)) ? 1 : 0;
	//assign vlan_lsb_nxt = ((be_tx_data_infifo[31:16] == `TYPE_VLAN) || (be_tx_data_infifo[31:16] == `TYPE_VLAN_QINQ)) ? 1 : 0;
	
	always @(posedge asclk) begin
		if(~aresetn) begin
			be_tx_data <= 0;
			be_tx_strb <= 0;
			tx_len_data_int <= 0;
			tx_spt_data_int <= 0;
			vlan_msb <= 0;
			vlan_lsb <= 0;
		end
		else begin
			be_tx_data <= be_tx_data_infifo;
			be_tx_strb <= be_tx_strb_infifo;
			tx_len_data_int <= tx_len_data;
			tx_spt_data_int <= tx_spt_data;
			vlan_msb <= vlan_msb_nxt;
			vlan_lsb <= vlan_lsb_nxt;
		end
	end
	
	//DL parsing
	always @* begin
		dl_start_nxt = 0;
		pkt_len_nxt = pkt_len;
		src_port_nxt = src_port;
		dl_dst_nxt = dl_dst;
		dl_src_nxt = dl_src;
		dl_ethtype_nxt = dl_ethtype;
		dl_vlantag_nxt = dl_vlantag;
		
		dl_tdata_nxt = be_tx_data;
		dl_tdata16_buf_nxt = dl_tdata16_buf;
		dl_tdata48_buf_nxt = dl_tdata48_buf;
		
		dl_done_nxt = 0;
		ip_start_nxt = 0;
		arp_start_nxt = 0;
		dl_valid_nxt = 0;
		dl_state_nxt = dl_state;
		
		case(dl_state)
			DL_WAIT_TVALID: begin
			end
			
			DL_PARSE_2ND: begin
			end
			
			DL_PARSE_MORE: begin
			end
			
			DL_SFT16_1ST: begin
			end
			
			DL_SFT16_MORE: begin
			end
			
			DL_SFT16_LAST: begin
			end
			
			DL_SFT48_1ST: begin
			end
			
			DL_SFT48_MORE: begin
			end
			
			DL_SFT48_LAST: begin
			end
		endcase
	end
	
	//Counters
	always @(posedge asclk) begin
		if(~aresetn) begin
			dl_parse_cnt <= 0;
			arp_parse_cnt <= 0;
			ip_tp_parse_cnt <= 0;
		end
		else begin
			if(dl_done) begin
				dl_parse_cnt <= dl_parse_cnt + 1;
			end
			if(arp_done) begin
				arp_parse_cnt <= arp_parse_cnt + 1;
			end
			if(ip_tp_done) begin
				ip_tp_parse_cnt <= ip_tp_parse_cnt + 1;
			end
		end
	end
	 
endmodule
