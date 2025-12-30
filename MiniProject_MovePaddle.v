


module MiniProject_MovePaddle #(
    parameter PADDLE_X_START_POSITION = 115,
    parameter PADDLE_Y_START_POSITION = 240,
    parameter PADDLE_Y_VELOCITY = 1,
	 parameter PADDLE_X_VELOCITY = 1 ,
    parameter MAX_TOP_POSITION = 185,
    parameter MIN_BOTTOM_POSITION = 305,
	 parameter MAX_LEFT_POSITION = 50,  // 设定球拍能到达的最左边界
    parameter MIN_RIGHT_POSITION = 180 // 设定球拍能到达的最右边界
)(   
    input           clock,
    input           reset,
    input   [3:0]   button,  //  Include move left and right, up and down
    output  [7:0]   paddleXValue,
    output  [8:0]   paddleYValue
    
);

// Local Variables
reg  [7:0]  xPaddlePosition = PADDLE_X_START_POSITION ;
reg  [8:0]  yPaddlePosition = PADDLE_Y_START_POSITION;  

always @ (posedge clock) begin
    if (reset) begin 
        xPaddlePosition = PADDLE_X_START_POSITION;
        yPaddlePosition = PADDLE_Y_START_POSITION;

    end else begin
        // Y-axis Movemeant
        
        // Move Down
        if (~button[0] && yPaddlePosition < MIN_BOTTOM_POSITION) begin
            yPaddlePosition <= yPaddlePosition + PADDLE_Y_VELOCITY;
        // Move Up
        end else if (~button[1] && yPaddlePosition > MAX_TOP_POSITION) begin
            yPaddlePosition <= yPaddlePosition - PADDLE_Y_VELOCITY;
        end
		  // Move left and right
		  if (~button[2] && xPaddlePosition > MAX_LEFT_POSITION) begin  // button[2]为低表示向左移动
            xPaddlePosition <= xPaddlePosition - PADDLE_X_VELOCITY;    // 向左移动
        end else if (~button[3] && xPaddlePosition < MIN_RIGHT_POSITION) begin  // button[3]为低表示向右移动
            xPaddlePosition <= xPaddlePosition + PADDLE_X_VELOCITY;    // 向右移动
        end
    end
end

// Assign Outputs
assign paddleXValue = xPaddlePosition;
assign paddleYValue = yPaddlePosition;

endmodule