// Author : Harisha B C
// Date   : 1-Apr-2026

//UART Receiver code
module uart_rx(
	input logic 		clk, 		// clock input
  	input logic 		rstn,		// active low reset
  	input logic			rxd,		// input receiver data
  	input logic 		tick,		// tick signal to sample the data correctly
  	
  	output logic 		rx_done,	// output signal showing receiving done
  	output logic [7:0]	data_out	// parallel data out
);
  
  // FSM state definition
  typedef enum logic[1:0] {
    IDLE,
    START,
    TRANS,
    STOP
  } state_t;
  
  // variables for storing FSM state
  state_t ps, ns;
  
  // Registers
  logic [7:0]	sbuf_reg, sbuf_next;
  logic [2:0]	count_reg, count_next;
  logic 		rx_done_next;
  
  // Sequential block
  always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      ps			<= IDLE;
      sbuf_reg		<= '0;
      count_reg		<= '0;
      rx_done		<= 1'b0;
    end else begin
      ps			<= ns;
      sbuf_reg		<= sbuf_next;
      count_reg		<= count_next;
      rx_done		<= rx_done_next;
    end
  end
  
  // Combinational logic block
  always_comb begin
    // defaults 
    ns				= ps;
    sbuf_next		= sbuf_reg;
    count_next		= count_reg;
    rx_done_next	= 1'b0;
    
    case (ps)
      
      IDLE: begin
        if (rxd == 1'b0) // detect start bit
          ns = START;
      end
      
      START: begin
        if (tick) begin
          count_next	= 0;
          ns 			= TRANS;
        end
      end
      
      TRANS: begin
        if (tick) begin
          // shift in received bit
          sbuf_next	= {rxd, sbuf_reg[7:1]};
          
          if(count_reg == 3'd7)
            ns = STOP;
          else
            count_next = count_reg + 1;
        end
      end
      
      STOP: begin
        if (tick) begin
          // optional: validate stop bit
          // if (rxd == 1)
          
          rx_done_next 	= 1'b1;
          ns			= IDLE;
        end
      end
    endcase
  end
  
  assign data_out = sbuf_reg;
  
endmodule