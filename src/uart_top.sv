// Author : Harisha B C
// Date   : 1-Apr-2026

//UART Top_Module Code
`include "baud_rate_gen.sv"
`include "uart_tx.sv"
`include "uart_rx.sv"
module UART #(
  parameter int unsigned CLK_FREQ 	= 1_000_000, // 1MHz
  parameter int unsigned BAUD_RATE 	= 9600
)(
	input logic 									clk,
  	input logic 									rstn,
  	input logic 									tx_start,
  	input logic [7:0]								data_in,
  	
  	output logic 									txd,
  	output logic 									tx_done,
  	output logic [7:0]								data_out,
  	output logic 									rx_done
);
  
  // Internal signals
  logic tick; 			// from baud_rate_gen to transmitter
  logic rxd_internal; 	// internal signal between TX and RX for easier debugging
  // logic [$clog2(CLK_FREQ/BAUD_RATE)-1:0] 	q;
  
  assign rxd_internal = txd;
  // Baud Rate Generator instantiation
  baudrate_gen #(
    .CLK_FREQ(CLK_FREQ),
    .BAUD_RATE(BAUD_RATE)
  ) BG (
    .clk(clk),
    .rstn(rstn),
    .tick(tick)
  );
  
  // UART Tx instantiation
  uart_tx TX (
    .clk(clk),
    .rstn(rstn),
    .tx_start(tx_start),
    .tick(tick),
    .data_in(data_in),
    .txd(txd),
    .tx_done(tx_done)
  );
  
  // UART Rx instantiation
  uart_rx RX (
    .clk(clk),
    .rstn(rstn),
    .rxd(rxd_internal), 
    .tick(tick),
    .data_out(data_out),
    .rx_done(rx_done)
  );
  
endmodule