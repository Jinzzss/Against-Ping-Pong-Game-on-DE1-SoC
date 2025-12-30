
/* CounterNbit_tb
 *---------------------------
 * By: Qimin Zhao
 * For: University of Leeds
 * Date: 29th April 2022 
 *
 * Short Description
 * -----------------
 * This is a testbench of CounterNbit module.
 * Reference: ELEC5566M - Unit2.1 - SynchronousTestBench_tb.v
              Benjamin Evans - CounterNbit_tb.v
 */ 

`timescale 1ns / 100ps

module CounterNBit_tb;

localparam NUM_CYCLES = 100; // Simulate this many clock cycles
localparam CLOCK_FREQ = 50000000; // Clock frequency in Hz
localparam RST_CYCLES = 2; // Number of cycles of reset at beginning
localparam WIDTH = 4; // Width of the counter

// Inputs
reg clock;
reg reset;
reg enable;

// Outputs
wire [WIDTH-1:0] countValue;

// Instantiate the CounterNBit Verilog module
CounterNBit #(
  .WIDTH(WIDTH),
  .INCREMENT(1),  // Increment by 1 each cycle when enabled
  .MAX_VALUE((2**WIDTH)-1)
) CounterNBit_dut (
  .clock(clock),
  .reset(reset),
  .enable(enable),
  .countValue(countValue)
);

// Clock generator + simulation time limit
initial begin
  reset = 1'b1;
  repeat(RST_CYCLES) @(posedge clock); // Wait for a couple of clock cycles
  reset = 1'b0;
end

initial begin
  clock = 1'b0;
  enable = 1'b0;
end

real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

// Generate the clock
integer half_cycles = 0;
always begin
  #(HALF_CLOCK_PERIOD); // Delay for half a clock period
  clock = ~clock; // Toggle the clock
  half_cycles = half_cycles + 1; // Increment the counter

  // Check if we have simulated enough half clock cycles
  if (half_cycles == (2*NUM_CYCLES)) begin
    half_cycles = 0; // Reset half cycles
    $stop; // Break the simulation
  end
end

// Test Bench Logic
initial begin
  // Print to console that the simulation has started
  $display("%d ns\tSimulation Started", $time);  

  enable = 1'b1; // Enable the counter
  #100; // Let the counter run for some time

  // Finished
  $display("%d ns\tSimulation Finished", $time);
  $finish; // Properly finish the simulation
end

endmodule
