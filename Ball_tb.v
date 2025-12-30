



`timescale 1ns / 100ps

// Test bench module declaration
module MoveBall_tb;

localparam NUM_CYCLES = 100; // Simulate this many clock cycles
localparam CLOCK_FREQ = 50000000; // Clock frequency (in Hz)
localparam RST_CYCLES = 2;        // Number of cycles of reset at beginning.

// Inputs
reg  clock;
reg  reset;
reg  changeXDirection;
reg  changeYDirection;

// Outputs
wire [7:0]   ballXValue;
wire [8:0]   ballYValue;
wire         direction;   // 1 = Right 

// Instantiate the MoveBall module Verilog code
MoveBall #(
  .BALL_X_START_POSITION    (209), // Start next to right paddle
  .BALL_Y_START_POSITION    (240),
  .BALL_X_VELOCITY          (1),   // Assume velocity parameter if the module uses it
  .BALL_Y_VELOCITY          (1)
) MoveBall_dut (
  .clock              (clock),
  .reset              (reset),
  .changeXDirection   (changeXDirection),
  .changeYDirection   (changeYDirection),
  .ballXValue         (ballXValue),
  .ballYValue         (ballYValue),
  .direction          (direction)
);

// Clock generator + simulation time limit
initial begin
  clock = 1'b0;
  forever #(50000000 / 2) clock = ~clock; // Generate a clock with 50MHz frequency
end

initial begin
  reset = 1'b1;
  repeat(RST_CYCLES) @(posedge clock); // Apply reset for a few clock cycles
  reset = 1'b0;
end

initial begin
  changeXDirection = 1'b0;
  changeYDirection = 1'b0;
end

// Test Bench Logic
initial begin
    $display("%d ns\tSimulation Started", $time);  

    // Test changing X direction
    @(posedge clock);
    changeXDirection = 1'b1;
    @(posedge clock);
    changeXDirection = 1'b0;

    #100; // Wait for the ball to move and direction to take effect

    // Check the effect of direction change on X
    @(posedge clock);
    if (direction == 1'b1 && ballXValue > 209) begin
        $display("Success! Ball moving right.");
    end else begin
        $display("Error! Ball not moving right as expected.");
    end

    // Test changing Y direction
    @(posedge clock);
    changeYDirection = 1'b1;
    @(posedge clock);
    changeYDirection = 1'b0;

    #100; // Wait for the ball to move and direction to take effect

    // Check the effect of direction change on Y
    @(posedge clock);
    if (ballYValue != 240) begin
        $display("Success! Ball Y position changed.");
    end else begin
        $display("Error! Ball Y position not changed as expected.");
    end

    // Finished
    $display("%d ns\tSimulation Finished", $time);
    $stop; // End simulation
end

endmodule

