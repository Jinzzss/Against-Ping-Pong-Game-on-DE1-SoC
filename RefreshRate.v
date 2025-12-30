
/* Refresh Rate
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * The module is mainly used to generate a refresh control signal 
   of a specific frequency.
	Reference :  Benjamin Evans -- Elec5566 Fpga design -  Refresh Rate.v
 */ 

module RefreshRate #(														
    parameter REFRESH_RATE = 100,                 // The frequency at which the output signal is high
    parameter MAX_VALUE = (50000000 / REFRESH_RATE) / 2, // The maximum value of the counter
    parameter WIDTH = 32,                         // Counter bit width
    parameter INCREMENT = 1                       // Counter increment
)(
    input     clock,                              // Input clock
    input     reset,                              // Input reset signal
    output reg refreshRate                        // Output refresh rate control signal
);

// Count value from CounterNBit module
wire [(WIDTH-1):0] countValue;                    // Net of count values

// Instantiate the CounterNBit module for counting up to MAX_VALUE
CounterNBit #(
    .WIDTH(WIDTH),              // Counter bit width
    .MAX_VALUE(MAX_VALUE),      // The maximum value of the counter
    .INCREMENT(INCREMENT)       // Counter increment
) CounterNBit(
    .clock(clock),              // Connect external clock
    .reset(reset),              // Connect external reset signal
    .enable(1'b1),              // Counter is always enabled
    .countValue(countValue)     // Connect the count value line network
);

// Generate a clock signal with a set frequency
always @(posedge clock or posedge reset) begin
    if (reset) begin
        refreshRate <= 1'b0;                     // If reset, the output signal is low
    end else if (countValue == MAX_VALUE - 1) begin
        refreshRate <= ~refreshRate;             // Toggle output signal when count reaches maximum value
    end
end

endmodule
