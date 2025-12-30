
/* MovePaddle 
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * This module control two paddles in a racket sports game,
   the paddle could move up and down.
 * 
 * Reference: Benjamin Evans - Elec5566 Fpga Design - MovePaddle.v
 */ 



// MovePaddle module definition, including the initial position and speed parameters of the racket
// Use parametric design to flexibly configure the initial position and movement speed of the racket
module MovePaddle #(
    parameter PADDLE_X_START_POSITION = 115,  // Racket initial X-axis position
    parameter PADDLE_Y_START_POSITION = 160,  // Racket initial Y-axis position
    parameter PADDLE_Y_VELOCITY = 1,          // Racket Y axis movement speed
	 parameter PADDLE_HEIGHT = 20, // Assume height of the racket is 20 pixels
    parameter MAX_TOP_POSITION = 10,         // The highest position of Y-axis
    parameter MIN_BOTTOM_POSITION = 305       // The lowest position of Y-axis
)(
    input           clock,         // Clock signal
    input           reset,         // Reset signal
    input   [1:0]   button,        // Control button, button[0] = moving down, button[1] = moving up
    output  [7:0]   paddleXValue,  // X-axis position output of racket
    output  [8:0]   paddleYValue   // Y-axis position output of racket
);

// Local variable used to store racket position
reg  [7:0]  xPaddlePosition = PADDLE_X_START_POSITION;  //X-axis position register
reg  [8:0]  yPaddlePosition = PADDLE_Y_START_POSITION;  // Y-axis position register

// Logic for handling paddle position
always @(posedge clock) begin
    if (reset) begin
        // Reset the position of the paddle
        yPaddlePosition <= PADDLE_Y_START_POSITION;
    end else begin
        // Handle the logic for moving down, making sure the bottom of the racket doesn't go past the bottom of the screen
        if (~button[0] && (yPaddlePosition + PADDLE_HEIGHT/2 + PADDLE_Y_VELOCITY <= MIN_BOTTOM_POSITION)) begin
            yPaddlePosition <= yPaddlePosition + PADDLE_Y_VELOCITY;
        end
        // Handle the logic for moving up, making sure the top of the racket doesn't go past the top of the screen
        else if (~button[1] && (yPaddlePosition - PADDLE_HEIGHT/2 - PADDLE_Y_VELOCITY >= MAX_TOP_POSITION)) begin
            yPaddlePosition <= yPaddlePosition - PADDLE_Y_VELOCITY;
        end
    end
end



// Assign the value of the internal register to the output
assign paddleXValue = xPaddlePosition;
assign paddleYValue = yPaddlePosition;

endmodule