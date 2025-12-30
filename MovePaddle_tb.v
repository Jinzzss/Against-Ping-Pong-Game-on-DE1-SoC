/* MovePaddle_tb
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * This module is a testbench of MovePaddle,
   to ensure that the paddle will not move out of the screen boundary. 
 * 
 * Reference: Benjamin Evans - Elec5566 Fpga Design - MovePaddle_tb.v
 */ 


`timescale 1 ns / 100 ps

module MovePaddle_tb;

localparam NUM_CYCLES = 100; // Simulate 100 clock cycles
localparam CLOCK_FREQ = 50000000; // Clock frequency
localparam RST_CYCLES = 2;        // Number of reset cycles

reg  clock;
reg  reset;
reg  paddleUp;
reg  paddleDown;

wire [7:0] paddleXValue;  // Wire to observe the X position of the paddle from the DUT
wire [8:0] paddleYValue;  // Wire to observe the Y position of the paddle from the DUT


// Instantiate the MovePaddle module with specific parameters
MovePaddle #(
    .PADDLE_X_START_POSITION    (315), // Set the starting X position of the paddle
    .PADDLE_Y_START_POSITION    (120), // Set the starting Y position at the center of the screen
    .PADDLE_Y_VELOCITY          (1),   // Set the velocity of paddle movement
    .MAX_TOP_POSITION           (10),  // Define the top boundary for the paddle
    .MIN_BOTTOM_POSITION        (230)  // Define the bottom boundary for the paddle
) MovePaddle_dut (
    .clock              (clock),
    .reset              (reset),
    .button             ({paddleUp, paddleDown}),
    .paddleXValue       (paddleXValue),
    .paddleYValue       (paddleYValue)
);


// Initial block to set up the clock and reset behavior
initial begin
    clock = 0;
    reset = 1;
    repeat (RST_CYCLES) @(posedge clock); // Maintain reset for a defined number of clock cycles
    reset = 0;
end


// Clock generation logic
always begin
    #5 clock = ~clock; 
end


// Initial block to perform specific test actions
initial begin
    paddleUp = 1; // Initially set both control signals to high (inactive)
    paddleDown = 1;

    
    @(posedge clock);  // Wait for the next clock edge
    reset = 0;
    paddleUp = 0; // Move up
    #20;
    paddleUp = 1; // Stop moving
    #10;
    if (paddleYValue != 10) begin
        $display("Error: Paddle did not stop at top boundary, paddleYValue = %d", paddleYValue);
    end else begin
        $display("Success: Paddle movement correctly bounded at the top");
    end

    // Terminate simulation
    $finish;
end

endmodule
