

/* CounterNbit
 *---------------------------
 * By: Qimin Zhao
 * For: University of Leeds
 * Date: 28th April 2022 
 *
 * Short Description
 * -----------------
 * This module is a configurable N bit counter, 
   mainly used to generate a counting sequence within a fixed range. 
 * Reference: ELEC5566M – Unit2.1 - CounterNBit.v
 */ 

module CounterNBit #(
    // Define parameters
    parameter WIDTH = 10,               // Counter bit width, default is 10 bits
    parameter INCREMENT = 1,            // The amount increased each cycle, default is 1
    parameter MAX_VALUE = (2**WIDTH)-1  // Maximum value, default is 2^WIDTH - 1
)(
    // Port definition
    input                    clock,
    input                    reset,
    input                    enable,
    output reg [(WIDTH-1):0] countValue  // Counter output value, width is WIDTH
);

// Local parameter, representing the zero value, used to reset the counter
localparam ZERO = {(WIDTH){1'b0}};

// Main always block, responds to rising edge of clock and rising edge of reset
always @(posedge clock or posedge reset) begin
    if (reset) begin
	 
        // When the reset signal is high, the counter is reset to 0
		  
        countValue <= ZERO;
		  
    end else if (enable) begin
        // When the enable signal is high, the counter increases according to the increment
		  
        if (countValue >= MAX_VALUE) begin
		  // If the current count value reaches or exceeds the maximum value, reset the counter to 0
            countValue <= ZERO;
				
        end else begin
            // Otherwise, the counter is incremented by the defined increment
            countValue <= countValue + INCREMENT;
        end
    end
end

endmodule

