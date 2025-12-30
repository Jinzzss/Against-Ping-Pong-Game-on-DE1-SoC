
/* MoveBall 
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * This module control two paddles in a small ball,
   the ball could move randomly across the screen.
 * 
 * Reference: Benjamin Evans - Elec5566 Fpga Design - MoveBall.v
 */ 


// MoveBall module definition, including the ball’s initial position and speed parameters
module MoveBall #(
    parameter BALL_X_START_POSITION = 115,
    parameter BALL_Y_START_POSITION = 160,  // The center of the screen
    parameter BALL_X_VELOCITY = 0.3,
    parameter BALL_Y_VELOCITY = 0.3,
    parameter MAX_TOP_POSITION = 5,         // Near the top
    parameter MIN_BOTTOM_POSITION = 315    // Near the bottom

)(   
    input           clock,
    input           reset,
    input           changeXDirection, // Hit Paddle
    input   [1:0]   changeYDirection, // Bit 1 = hit top half, Bit 0 = hit bottom half
    output  [7:0]   ballXValue,     // Current X position of the ball
    output  [8:0]   ballYValue,     // Current Y position of the ball
    output          direction      // Current horizontal direction of the ball (0 = left, 1 = right)
 
);

// Local Variables
reg  [7:0]  xBallPosition = BALL_X_START_POSITION;
reg  [8:0]  yBallPosition = BALL_Y_START_POSITION; 
reg         xDirection = 1'b0; // 1 = Right, 0 = Left
reg         yDirection = 1'b0; // 1 = Down, 0 = Up

always @ (posedge clock) begin
    if (reset) begin 
        // Causes next ball to be served towards to conceding point player in a random direction
        // as only resetting x psotion 
        xBallPosition = BALL_X_START_POSITION;

    end else begin
         // Check if there is a request to change the horizontal direction
        if (changeXDirection) begin
            // Right paddle hit condition, with a buffer zone
            if (ballXValue >= 220 - 5 - 5) begin
                 xDirection <= 1'b0;
            end

            // Left paddle hit condition, with a buffer zone
            if (ballXValue <= 20 + 5 + 5) begin
                 xDirection <= 1'b1;
            end
        end

        // Movement logic for horizontal direction
        if (xDirection) begin
            xBallPosition <= xBallPosition + BALL_X_VELOCITY;
        // Move Left
        end else if (~xDirection) begin
            xBallPosition <= xBallPosition - BALL_X_VELOCITY;
        end


        // Y-axis Movemeant
        // Hit Top half of Paddles
        if (changeYDirection[1]) begin
            // Ball Moving Down
            if (yDirection == 1'b1) begin
                yDirection <= 1'b0; // Change to Move Upwards
            end

        // Hit bottom half of paddles
        end else if (changeYDirection[0]) begin 
            // Ball Moving up
            if (yDirection == 1'b0) begin
                yDirection <= 1'b1; // Change to Move Down
            end
        end

        // Bounce of top and bottom walls 
        if (yDirection && yBallPosition >  MIN_BOTTOM_POSITION) begin 
            yDirection <= ~yDirection;
        end else if (~yDirection && yBallPosition <  MAX_TOP_POSITION) begin
            yDirection <= ~yDirection;
        end 
        
        // Move Down
        if (yDirection) begin
            yBallPosition <= yBallPosition + BALL_Y_VELOCITY;
        // Move Up
        end else if (~yDirection ) begin
            yBallPosition <= yBallPosition - BALL_Y_VELOCITY;
        end
    end
end

// Assign Outputs
assign ballXValue = xBallPosition;
assign ballYValue = yBallPosition;
assign direction = xDirection;

endmodule