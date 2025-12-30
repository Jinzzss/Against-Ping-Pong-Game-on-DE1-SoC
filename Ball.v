




module Ball #(
    parameter BALL_X_START_POSITION = 115,  // 球的起始X坐标
    parameter BALL_Y_START_POSITION = 240,  // 球的起始Y坐标
    parameter BALL_X_VELOCITY = 1,          // 球的X轴速度
    parameter BALL_Y_VELOCITY = 1,          // 球的Y轴速度
    parameter MAX_TOP_POSITION = 175,       // 球可达到的最顶部位置
    parameter MIN_BOTTOM_POSITION = 310     // 球可达到的最底部位置
)(
    input           clock,
    input           reset,
    input           changeXDirection,       // 检测到击中球拍时改变X方向
    input   [1:0]   changeYDirection,       // 检测到击中球拍的上半部或下半部时改变Y方向
    output  [7:0]   ballXValue,
    output  [8:0]   ballYValue,
    output          direction               // 球的当前水平方向（1=向右，0=向左）
);

// 本地变量
reg  [7:0]  xBallPosition = BALL_X_START_POSITION;  // 球的当前X坐标
reg  [8:0]  yBallPosition = BALL_Y_START_POSITION;  // 球的当前Y坐标
reg         xDirection = 1'b0;                      // 初始化方向向左
reg         yDirection = 1'b0;                      // 初始化方向向上

always @ (posedge clock) begin
    if (reset) begin 
        // 重置时只设置X坐标，随机设置Y方向
        xBallPosition = BALL_X_START_POSITION;
    end else begin
        // X轴移动逻辑
        // 检测到击中球拍时改变X方向
        if (changeXDirection) begin
            // 右侧球拍
            if (xBallPosition >= 220 - 5 - 5) begin
                xDirection <= 1'b0;  // 改变方向向左
            end
            // 左侧球拍
            if (xBallPosition <= 20 + 5 + 5) begin
                xDirection <= 1'b1;  // 改变方向向右
            end
        end

        // 根据方向移动球
        if (xDirection) begin
            xBallPosition <= xBallPosition + BALL_X_VELOCITY;
        end else begin
            xBallPosition <= xBallPosition - BALL_X_VELOCITY;
        end

        // Y轴移动逻辑
        // 检测到击中球拍的上半部或下半部时改变Y方向
        if (changeYDirection[1]) begin
            if (yDirection == 1'b1) begin
                yDirection <= 1'b0;  // 向上移动
            end
        end else if (changeYDirection[0]) begin
            if (yDirection == 1'b0) begin
                yDirection <= 1'b1;  // 向下移动
            end
        end

        // 在顶部和底部边界反弹
        if (yDirection && yBallPosition > MIN_BOTTOM_POSITION) begin 
            yDirection <= ~yDirection;
        end else if (~yDirection && yBallPosition < MAX_TOP_POSITION) begin
            yDirection <= ~yDirection;
        end 

        // 根据方向移动球
        if (yDirection) begin
            yBallPosition <= yBallPosition + BALL_Y_VELOCITY;  // 向下移动
        end else if (~yDirection) begin
            yBallPosition <= yBallPosition - BALL_Y_VELOCITY;  // 向上移动
        end
    end
end

// 输出赋值
assign ballXValue = xBallPosition;  // 输出球的当前X坐标
assign ballYValue = yBallPosition;  // 输出球的当前Y坐标
assign direction = xDirection;      // 输出球的当前移动方向（向右为1，向左为0）

endmodule
