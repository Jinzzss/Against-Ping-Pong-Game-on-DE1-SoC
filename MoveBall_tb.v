

/* MoveBall_tb
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * This module is a testbench of MoveBall,
   to ensure that the small ball will not move out of the screen boundary. 
 * 
 * Reference: Benjamin Evans - Elec5566 Fpga Design - MovePaddle_tb.v
 */
 

`timescale 1 ns / 100 ps

module MoveBall_tb;

localparam NUM_CYCLES = 100; //Simulate so many clock cycles
localparam CLOCK_FREQ = 50000000; // Clock Frequency
localparam RST_CYCLES = 2;        // Number of reset cycles to start with.
localparam WAIT_TIME = 1000;      // Waiting time, increased to accommodate the slowing down of the ball

// Inputs
reg  clock;
reg  reset;
reg  changeXDirection;
reg  [1:0]  changeYDirection;  // Use 2 bits to simulate Y-axis collision to test different collision directions

// Outputs
wire [7:0]   ballXValue;
wire [8:0]   ballYValue;
wire         direction;   // 1 = right, 0 = left

// Instantiate the MoveBall Verilog module
MoveBall #(
  .BALL_X_START_POSITION    (160), // Screen center X
  .BALL_Y_START_POSITION    (120), // Screen center Y
  .MAX_TOP_POSITION         (5),   // Top border position
  .MIN_BOTTOM_POSITION      (235)  // Bottom border position
) MoveBall_dut (
  .clock              (clock              ),
  .reset              (reset              ),
  .changeXDirection   (changeXDirection   ),
  .changeYDirection   (changeYDirection   ),
  .ballXValue         (ballXValue         ),
  .ballYValue         (ballYValue         ),
  .direction          (direction          )
);

// Clock generator and simulation time limits
initial begin
  clock = 1'b0;
  reset = 1'b1;
  repeat(RST_CYCLES) @(posedge clock); // Remains in reset state for the initial clock cycle
  reset = 1'b0;
end

//Define the length of half a clock cycle

real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

// Generate clock
integer half_cycles = 0;
always begin
    #(HALF_CLOCK_PERIOD);          // Wait half a clock cycle
    clock = ~clock;                // Switch the high and low states of the clock signal
    half_cycles = half_cycles + 1; // Increment counter

    if (half_cycles == (2 * NUM_CYCLES)) begin 
        $stop;                      // Terminate simulation
    end
end

// Testbench logic
initial begin
    $display("%d ns\tSimulation start", $time);  

    #40;
    changeXDirection = 1'b1;       // Trigger the ball to change horizontal direction
    @(posedge clock);
    changeXDirection = 1'b0;

    #WAIT_TIME; // Increase the waiting time to ensure that the ball has time to move

    // Check that the ball moves to the expected position
    if (direction == 1'b1 && ballXValue > 160) begin
        $display("Success: The ball moves to the right");
    end else begin
        $display("Error: The ball did not move correctly to the right");
    end

    changeXDirection = 1'b1;
    @(posedge clock);
    changeXDirection = 1'b0;

    #WAIT_TIME; // Wait for the ball to bounce

        // Check if the ball moves to the left
    if (direction == 1'b0 && ballXValue < 160) begin
        $display("Success: The ball moves to the left");
    end else begin
        $display("Error: The ball did not move correctly to the left");
    end

    // Check movement in Y direction (optional, if you need to test Y direction)
    changeYDirection = 2'b01;  // Assumption 1 means top collision rebound
    @(posedge clock);
    changeYDirection = 2'b00;

    #WAIT_TIME; // Wait for the ball to move and bounce in the Y direction

    if (direction == 1'b0 && ballYValue < 120) begin
        $display("Success: The ball moves up and bounces");
    end else begin
        $display("Error: The ball failed to move or bounce correctly in the Y direction");
    end

    // Additional tests can be added as needed

    $display("%d ns\t Terminate simulation", $time);
    $finish; // Terminate Simulation
end
endmodule