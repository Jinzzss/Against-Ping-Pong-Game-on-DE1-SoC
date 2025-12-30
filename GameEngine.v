
/* GameEngine
 *---------------------------
 * By: Qimin Zhao
 * For: University of Leeds
 * Date: 29th April 2024 
 *
 * Short Description
 * -----------------
 * This module manages game logic, display interfacing, 
   and input handling for a basic ball and paddle game.
 * 
 * Reference: Thomas Carpenter - Elec5566 Fpga Design - LT24Top.v
 */ 

// GameEngine Module Definition with parameters for the game's physical attributes
module GameEngine #(
    parameter BALL_SIZE = 5,         // Diameter of the ball in pixels
    parameter PADDLE_WIDTH = 5,      // Width of the paddle in pixels
    parameter PADDLE_HIGHT = 20      // Hight of the paddle in pixels
)(
    // Global Clock/Reset/Pause
    input              clock,     // System clock
    input              reset,     // System reset signal
    output             resetApp,  // Reset signal specifically for application logic
  
    // Inputs from the game interface
    input              rightPaddleUp,   // Signal to move the right paddle up
    input              rightPaddleDown, // Signal to move the right paddle down

    // Outputs to the seven segment displays for score or other displays
    output [6:0]       segFour,
    output [6:0]       segFive,
    output [6:0]       segZero,
    output [6:0]       segOne,

    // Outputs to control the LT24 LCD display
    output             LT24Wr_n,
    output             LT24Rd_n,
    output             LT24CS_n,
    output             LT24RS,
    output             LT24Reset_n,
    output [15:0]      LT24Data,
    output             LT24LCDOn
);

// Declare internal variables for display and gameplay logic
// Variables for handling LCD display
reg  [ 7:0] xAddr;                  // Current X address for updating pixels
reg  [ 8:0] yAddr;                  // Current Y address for updating pixels
reg  [15:0] pixelData;              // Data for the current pixel to be displayed
wire        pixelReady;             // Flag from display controller indicating ready to receive new pixel data
reg         pixelWrite;             // Control signal to write data to the display
wire        refreshClockPaddles;    // Refresh clock for updating paddle positions
wire        refreshClockBall;       // Refresh clock for updating ball position

// Variables for gameplay dynamics
wire [7:0]  xBallPosition;         // X coordinate of the ball
wire [8:0]  yBallPosition;         // Y coordinate of the ball
wire        ballPaddleCollision;         // Collision detection between ball and paddles
wire [1:0]  ballPaddleHalfCollision; // Detailed collision detection for top and bottom halves of the paddles
wire        direction;                   // Direction of the ball's movement
reg         resetBall = 1'b0;             // Signal to reset the ball position

// Variables for right paddle control
wire [7:0]  xPaddleRightPosition;  // X coordinate of the right paddle
wire [8:0]  yPaddleRightPosition;  // Y coordinate of the right paddle

// Variables for the left paddle control (used for AI or second player)
reg         leftPaddleUp;                 // Simulated input for moving the left paddle up
reg         leftPaddleDown;               // Simulated input for moving the left paddle down
wire [7:0]  xPaddleLeftPosition;   // X coordinate of the left paddle
wire [8:0]  yPaddleLeftPosition;   // Y coordinate of the left paddle

// Scoring system variables
reg  [7:0]  leftPaddleScore;        // Score counter for the left paddle
reg  [7:0]  rightPaddleScore;       // Score counter for the right paddle
wire [11:0] leftPaddleBCD;        // BCD encoded value of the left paddle's score
wire [11:0] rightPaddleBCD;       // BCD encoded value of the right paddle's score

// Collision detection logic to determine if the ball has hit the paddles
assign ballPaddleCollision = (
    (yBallPosition >= yPaddleRightPosition - PADDLE_HIGHT - BALL_SIZE &&
     yBallPosition <= yPaddleRightPosition + PADDLE_HIGHT + BALL_SIZE &&
     xBallPosition == xPaddleRightPosition - PADDLE_WIDTH - BALL_SIZE) ||
    (yBallPosition >= yPaddleLeftPosition - PADDLE_HIGHT - BALL_SIZE &&
     yBallPosition <= yPaddleLeftPosition + PADDLE_HIGHT + BALL_SIZE &&
     xBallPosition == xPaddleLeftPosition + PADDLE_WIDTH + BALL_SIZE)
    ) ? 1'b1 : 1'b0;

// Further detail collision detection for top and bottom half impacts
assign ballPaddleHalfCollision[1] = (
    (yBallPosition >= yPaddleRightPosition - PADDLE_HIGHT - BALL_SIZE &&
     yBallPosition <= yPaddleRightPosition &&
     xBallPosition == xPaddleRightPosition - PADDLE_WIDTH - BALL_SIZE) ||
    (yBallPosition >= yPaddleLeftPosition - PADDLE_HIGHT - BALL_SIZE &&
     yBallPosition <= yPaddleLeftPosition &&
     xBallPosition == xPaddleLeftPosition + PADDLE_WIDTH + BALL_SIZE)
    ) ? 1'b1 : 1'b0;

assign ballPaddleHalfCollision[0] = (
    (yBallPosition <= yPaddleRightPosition + PADDLE_HIGHT + BALL_SIZE &&
     yBallPosition >= yPaddleRightPosition &&
     xBallPosition == xPaddleRightPosition - PADDLE_WIDTH - BALL_SIZE) ||
    (yBallPosition <= yPaddleLeftPosition + PADDLE_HIGHT + BALL_SIZE &&
     yBallPosition >= yPaddleLeftPosition &&
     xBallPosition == xPaddleLeftPosition + PADDLE_WIDTH + BALL_SIZE)
    ) ? 1'b1 : 1'b0;


// Instantiation of the LT24 display module
// LCD Display Module
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clock      ),
    .globalReset (reset      ),
    //Reset for User Logic
    .resetApp    (resetApp   ),
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

//Counters for managing pixel addressing on the LCD
// X Counter
wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH     (         8 ),
    .MAX_VALUE (LCD_WIDTH-1)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);

// Y Counter
wire [8:0] yCount;
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
UpCounterNbit #(
    .WIDTH     (           9),
    .MAX_VALUE (LCD_HEIGHT-1)
) yCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (yCntEnable),
    .countValue(yCount    )
);



//Modules to manage the refresh rates of paddles and ball
// Refresh Rate For Paddles
RefreshRate #(
    .REFRESH_RATE (110)				
) RefreshRatePaddles (
    .clock           (clock	  	         ),			
    .reset		  	   (reset	            ),
    .refreshRate    	(refreshClockPaddles )
);

// Refresh Rate For Ball
RefreshRate #(
    .REFRESH_RATE (140)				
) RefreshRateBall (
    .clock           (clock	  	        ),			
    .reset		  	   (reset	           ),
    .refreshRate    	(refreshClockBall   )
);


// Instantiates the MoveBall module to handle ball physics and movement
MoveBall #(
    .BALL_X_VELOCITY      (1),  // Set the horizontal velocity of the ball
    .BALL_Y_VELOCITY      (1)   // Set the vertical velocity of the ball
) MoveBall (
    .clock              (refreshClockBall),          // Clock signal for ball movement timing
    .reset              (resetBall),                  // Reset signal for the ball
    .changeXDirection   (ballPaddleCollision),        // Signal to change X direction on paddle collision
    .changeYDirection   (ballPaddleHalfCollision),    // Signal to change Y direction on specific paddle collision
    .ballXValue         (xBallPosition),              // Current X position of the ball
    .ballYValue         (yBallPosition),              // Current Y position of the ball
    .direction          (direction)                   // Current movement direction of the ball
);

// Instantiates the MovePaddle module for the right paddle
MovePaddle #(
    .PADDLE_X_START_POSITION    (220),  // Initial X position of the right paddle
    .PADDLE_Y_START_POSITION    (240)   // Initial Y position of the right paddle
) MovePaddleRight (
    .clock              (refreshClockPaddles),         // Clock signal for paddle movement timing
    .reset              (resetApp),                    // Reset signal for the paddle
    .button             ({rightPaddleUp,rightPaddleDown}), // Button inputs for moving the paddle
    .paddleXValue       (xPaddleRightPosition),        // Current X position of the right paddle
    .paddleYValue       (yPaddleRightPosition)         // Current Y position of the right paddle
);

// Instantiates the MovePaddle module for the left paddle
MovePaddle #(
    .PADDLE_X_START_POSITION    (20),   // Initial X position of the left paddle
    .PADDLE_Y_START_POSITION    (240)   // Initial Y position of the left paddle
) MovePaddleLeft (
    .clock              (refreshClockPaddles),         // Clock signal for paddle movement timing
    .reset              (resetApp),                    // Reset signal for the paddle
    .button             ({leftPaddleUp,leftPaddleDown}), // Button inputs for moving the paddle
    .paddleXValue       (xPaddleLeftPosition),         // Current X position of the left paddle
    .paddleYValue       (yPaddleLeftPosition)          // Current Y position of the left paddle
);

// Modules to display the score of the left paddle on seven segment displays
HexTo7Segment LeftPaddleScoreFive (
    .hex (leftPaddleBCD[7:4]),  // High nibble of the BCD score
    .seg (segFive)              // Connect to the seven segment display
);
HexTo7Segment LeftPaddleScoreFour (
    .hex (leftPaddleBCD[3:0]),  // Low nibble of the BCD score
    .seg (segFour)              // Connect to the seven segment display
);
BinaryToBCD LeftPaddleBCD (
    .bin (leftPaddleScore),     // Binary score input
    .bcd (leftPaddleBCD)        // BCD output
);

// Modules to display the score of the right paddle on seven segment displays
HexTo7Segment RightPaddleScoreOne (
    .hex (rightPaddleBCD[7:4]), // High nibble of the BCD score
    .seg (segOne)               // Connect to the seven segment display
);
HexTo7Segment RightPaddleScoreZero (
    .hex (rightPaddleBCD[3:0]), // Low nibble of the BCD score
    .seg (segZero)              // Connect to the seven segment display
);
BinaryToBCD RightPaddleBCD (
    .bin (rightPaddleScore),    // Binary score input
    .bcd (rightPaddleBCD)       // BCD output
);



// Procedural block to control the pixel writing to the display
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
        //In this example we always set write high, and use pixelReady to detect when
        //to update the data.
        pixelWrite <= 1'b1;
        //You could also control pixelWrite and pixelData in a State Machine.
    end
end

// Procedural block to handle drawing of game elements
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelData           <= 16'b0;
        xAddr               <= 8'b0;
        yAddr               <= 9'b0;
    end else if (pixelReady) begin
        //X/Y Address are just the counter values
        xAddr               <= xCount;
        yAddr               <= yCount;

        // set whole new screen frame black
        pixelData    <= 16'h0000;  
        
        // Drawing logic for game elements
        // Draw the ball
        if (xCount > xBallPosition - BALL_SIZE && xCount < xBallPosition + BALL_SIZE && 
        yCount > yBallPosition - BALL_SIZE && yCount < yBallPosition + BALL_SIZE) begin 
            pixelData    <= 16'hFFFF;
        end 
        
       // Draw Right Paddle
        if (xCount > xPaddleRightPosition - PADDLE_WIDTH && xCount < xPaddleRightPosition + PADDLE_WIDTH && 
         yCount > yPaddleRightPosition - PADDLE_HIGHT && yCount < yPaddleRightPosition + PADDLE_HIGHT) begin 
         pixelData <= 16'hF800; // Set pixel data for the right paddle (red)
        end 

       // Draw Left Paddle
        if (xCount > xPaddleLeftPosition - PADDLE_WIDTH && xCount < xPaddleLeftPosition + PADDLE_WIDTH && 
         yCount > yPaddleLeftPosition - PADDLE_HIGHT && yCount < yPaddleLeftPosition + PADDLE_HIGHT) begin 
         pixelData <= 16'h001F; // Set pixel data for the left paddle (blue)
        end 
 

        // Draw Top Wall
        if (yCount < 5) begin 
            pixelData    <= 16'h3186; // Color of the top wall
        end

        // Draw Bottom Wall
        if (yCount >= LCD_HEIGHT - 5) begin 
            pixelData    <= 16'h3186; // Color of the bottom wall
        end
        
        // Draw Left Wall
        if (xCount < 5) begin 
            pixelData    <= 16'h3186; // Color of the left wall
        end
        
        // Draw Right Wall
        if (xCount >= LCD_WIDTH - 5) begin 
            pixelData    <= 16'h3186; // Color of the right wall
        end
    end
end


// Procedural block to simulate left paddle AI movement based on ball direction
always @(posedge clock) begin
    // Stop moving if ball is moving away
    leftPaddleDown <= 1'b1;
    leftPaddleUp <= 1'b1;

    // Ball is moving left - try to hit ball
    if (direction == 0) begin
        // Ball Lower than paddle
        if (yPaddleLeftPosition >= yBallPosition) begin
            leftPaddleDown <= 1'b1;
            leftPaddleUp <= 1'b0;

        // Ball higher than paddle
        end else if (yPaddleLeftPosition < yBallPosition)begin
            leftPaddleUp <= 1'b1;
            leftPaddleDown <= 1'b0;
        end

    // Ball is moving right - move paddle to middle
    end else begin 
        // Paddle Higher than middle
        if (yPaddleLeftPosition > 241) begin
            leftPaddleDown <= 1'b1;
            leftPaddleUp <= 1'b0;

        // Paddle Lower than middle
        end else if (yPaddleLeftPosition < 239)begin
            leftPaddleUp <= 1'b1;
            leftPaddleDown <= 1'b0;
        end else begin
            leftPaddleDown <= 1'b1;
            leftPaddleUp <= 1'b1;
        end 
    end 
end

// Score calculation based on the position of the ball relative to the goals
always @(posedge refreshClockBall) begin 
    if (resetApp) begin
        // Reset scores when the game is reset
        leftPaddleScore <= 4'b0;
        rightPaddleScore <= 4'b0;
        
    end else begin
        resetBall <= 1'b0;

        // Left paddle scores when the ball hits a specific X position
        if (xBallPosition == 230) begin 
            resetBall <= 1'b1;
            leftPaddleScore <= leftPaddleScore + 1'b1;

            // Check if the left paddle has reached 6 points and reset if true
            if (leftPaddleScore == 6) begin
                leftPaddleScore <= 4'b0;
                rightPaddleScore <= 4'b0;
            end

        // Right paddle scores when the ball hits a specific X position
        end else if (xBallPosition == 5) begin 
            resetBall <= 1'b1;
            rightPaddleScore <= rightPaddleScore + 1'b1;

            // Check if the right paddle has reached 6 points and reset if true
            if (rightPaddleScore == 6) begin
                leftPaddleScore <= 4'b0;
                rightPaddleScore <= 4'b0;
            end
        end 
    end
end


endmodule
