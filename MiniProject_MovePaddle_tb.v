




`timescale 1 ns/100 ps

// Test bench module declaration

module MiniProject_MovePaddle_tb;

// 定义模拟的参数
localparam NUM_CYCLES = 25000; // 模拟的时钟周期数
localparam CLOCK_FREQ = 50000000; // 时钟频率为50 MHz
localparam RST_CYCLES = 2;        // 初始时，复位信号持续的周期数

// 输入信号
reg  clock;
reg  reset;
reg  paddleUp;
reg  paddleDown;
reg  paddleLeft;
reg  paddleRight;

// 输出信号
wire [7:0]   paddleXValue;
wire [8:0]   paddleYValue;

// 实例化 MovePaddle 模块
MovePaddle MovePaddle_dut (
    .clock              (clock          ),
    .reset              (reset          ),
    .button             ({paddleUp, paddleDown, paddleLeft, paddleRight}),
    .paddleXValue       (paddleXValue   ),
    .paddleYValue       (paddleYValue   )
);  

// 时钟生成器及模拟时间限制
initial begin
  reset = 1'b1;
  repeat(RST_CYCLES) @(posedge clock); // 等待几个时钟周期以维持复位
  reset = 1'b0;
end

initial begin
  clock = 1'b0;
  paddleUp = 1'b1;
  paddleDown = 1'b1;
  paddleLeft = 1'b1;
  paddleRight = 1'b1;
end

real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

// 生成时钟信号
integer half_cycles = 0;
always begin
    #(HALF_CLOCK_PERIOD);          // 延迟半个时钟周期
    clock = ~clock;                // 切换时钟信号
    half_cycles = half_cycles + 1; // 增加半周期计数
    
    // 检查是否已模拟足够的时钟半周期
    if (half_cycles == (2 * NUM_CYCLES)) begin 
        half_cycles = 0;           // 重置半周期计数
        $stop;                     // 停止模拟
        // 注：可以通过 "run -continue" 或 "run ### ns" 在 Modelsim 中继续模拟。
    end
end

// 测试逻辑
initial begin
    $display("%d ns\tSimulation Started", $time); // 输出模拟开始的信息

    #40;
    
    // 通过所有可能的移动方向，检查球拍的x和y位置是否按预期更新

    // 检查向上移动一次
    @(posedge clock);
    paddleUp = 1'b0;
    @(posedge clock);
    paddleUp = 1'b1;
    #20;
    if (paddleYValue == 239) begin 
        $display("Success!");
    end else begin
        $display("Error!");
    end

    // 检查向下移动一次
    @(posedge clock);
    paddleDown = 1'b0;
    @(posedge clock);
    paddleDown = 1'b1;
    #20;
    if (paddleYValue == 240) begin 
        $display("Success!");
    end else begin
        $display("Error!");
    end
    
    // 检查向左移动一次
    @(posedge clock);
    paddleLeft = 1'b0;
    @(posedge clock);
    paddleLeft = 1'b1;
    #20;
    if (paddleXValue < 115) begin // 假设初始位置减去一个单位
        $display("Success!");
    end else begin
        $display("Error!");
    end

    // 检查向右移动一次
    @(posedge clock);
    paddleRight = 1'b0;
    @(posedge clock);
    paddleRight = 1'b1;
       #20;
    if (paddleXValue > 115) begin // 假设初始位置加上一个单位
        $display("Success!");
    end else begin
        $display("Error! Expected paddleXValue to be greater than 115, got %d", paddleXValue);
    end

    // Test completion and finalization
    $display("%d ns\tSimulation Finished", $time);

    // Stop the simulation
    $finish;
end
endmodule
