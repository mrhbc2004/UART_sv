// Author : Harisha B C
// Date   : 2-Apr-2026

//UART Basic Testbench

`timescale 1ns/1ps

module uart_tb;
  
  // Testbench signals
  logic			clk;
  logic 		rstn;
  logic 		tx_start;
  logic [7:0]	data_in;
  
  logic 		txd;
  logic 		tx_done;
  logic [7:0]	data_out;
  logic 		rx_done;
  
  // Instantiate DUT
  UART dut(
    .clk(clk),
    .rstn(rstn),
    .tx_start(tx_start),
    .data_in(data_in),
    .txd(txd),
    .tx_done(tx_done),
    .data_out(data_out),
    .rx_done(rx_done)
  );
  
  
  // Clock generation (1 MHz -> period = 1000ns)
  always #500 clk = ~clk;
  
  // Reset task
  task reset_dut();
    begin
      rstn		= 0;
      tx_start	= 0;
      data_in	= 0;
      #2000;
      rstn		= 1;
    end
  endtask
  
  // Task to send data
  task send_data (logic [7:0] data);
    begin
      @(posedge clk);
      data_in	= data;
      tx_start	= 1;
      
      @(posedge clk);
      tx_start	= 0;
      
      // wait for transmission to complete
      wait(tx_done);
      
      // wait for reception
      wait(rx_done);
      
      // small delay for stability
      #1000;
      
      // check result
      if (data_out == data) begin
        $display("PASS: SENT= %0h, Received = %0h",data,data_out);
      end
      else begin
        $display("FAIL: SENT= %0h, Received = %0h",data,data_out);
      end
    end
  endtask
  
  // initial block (main test sequence)
  initial begin
    $display("STARTING UART TESTBENCH....");
    
    clk = 0;
    
    reset_dut();
    
    // TEST_CASES
    send_data($urandom_range(1,255));
    send_data($urandom_range(1,255));
    send_data($urandom_range(1,255));
    send_data($urandom_range(1,255));
    send_data($urandom_range(1,255));
    
    $display("ALL TESTS COMPLETED");
    
    #5000;
    $finish;
  end
  
  // Monitor signals 
  initial begin
    $monitor("TIME: %ot | txd = %b | tx_done = %b| rx_done = %b | data_out = %h",$time,txd,tx_done,rx_done,data_out);
  end
  
  // Initial block to dumpvars
  initial begin
    $dumpvars();
    $dumpfile("dump.vcd");
  end
  
endmodule