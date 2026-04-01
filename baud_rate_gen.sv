// Author: Harisha B C 
// Date  : 31 Mar 2026
// BAUD_RATE GENERATOR
module baudrate_gen #( // Parameterized for clk and baud_rate
	parameter int unsigned CLK_FREQ 		= 1_000_000, // 1MHz
  	parameter int unsigned BAUD_RATE 		= 9600
)(
  input  logic                                      clk,  // clock input
  input  logic										rstn, // active low reset
  output logic [$clog2(CLK_FREQ/BAUD_RATE)-1:0] 	q, 	  // dynamic size of bitwidth taken by BAUD_DIV
  output logic										tick  // intended baud rate pulse (not used)
);
  
  // compile time constant
  localparam int unsigned BAUD_DIV = `CLK / `BAUD_RATE;
  
  // core logic
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      q <= '0;
    end
    else begin
      // The value 103 is decided by dividing clk by desired baud_rate
      if (q == BAUD_DIV) begin
        q <= '0; // reset the counter if the counter value is 103
      end else begin
        q <= q + 1; // otherwise increment the counter
      end
    end
  end
  
  // Tick is raised when it reaches the desired baud_count
  assign tick = (q == (BAUD_DIV-1));
endmodule