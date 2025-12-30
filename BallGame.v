
/* BallGame
 *---------------------------
 * By: Qimin Zhao
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 * This module implements a simple game system based on an LT24 display and a seven-segment digital tube. 
   The components of the code include input and output definitions, 
   instantiation of the game engine, the dithering module, and the main state machine for the game.
 * 
 * Reference: Thomas Carpenter - Elec5566 Fpga Design - LT24Top.v
 */ 

// Definition of the BallGame module

module BallGame (    
    // Definition of input signals
    input clock, // Main clock signal
    input key0,  // Up
    input key1,  // Down
    input key2,  // Play
    input key3,  // Menu
 
    // Seven Segment Displays 
    output [6:0] segZero, // Seven-segment display 0
    output [6:0] segOne,  // Seven-segment display 1
    output [6:0] segFour, // Seven-segment display 4
    output [6:0] segFive, // Seven-segment display 5

    // LT24 display interface outputs
    output        resetApp,
    output        LT24Wr_n,
    output        LT24Rd_n,
    output        LT24CS_n,
    output        LT24RS,
    output        LT24Reset_n,
    output [15:0] LT24Data,
    output        LT24LCDOn
); 

// Local Variables definitions
reg clockControl;        // Register to control the game engine clock
reg reset;               // Game reset signal
wire gameOver;           // Game over signal
wire synchronisedkey2;   // Debounced start game button signal
wire synchronisedkey3;   // Debounced menu button signal

//Instantiation of Game Engine
GameEngine GameEngine(
    // Inputs
    .clock              (clockControl),
    .reset              (reset       ),
    .rightPaddleUp      (key0        ),
    .rightPaddleDown    (key1        ),

    // Seven Segment Displays 
    .segFour            (segFour     ),
    .segFive            (segFive     ),
    .segZero            (segZero     ),
    .segOne             (segOne      ),

    // LT24 Interface
    .resetApp           (resetApp    ),
    .LT24Wr_n           (LT24Wr_n    ),
    .LT24Rd_n           (LT24Rd_n    ),
    .LT24CS_n           (LT24CS_n    ),
    .LT24RS             (LT24RS      ),
    .LT24Reset_n        (LT24Reset_n ),
    .LT24Data           (LT24Data    ),
    .LT24LCDOn          (LT24LCDOn   )
);

//Instanitiation of Debouncing moudle
Debouncer DebouncerKey2 (
    .clock      (clock),
    .asyncIn    (key2),
    .syncOut    (synchronisedkey2)
);

Debouncer DebouncerKey3 (
    .clock      (clock),
    .asyncIn    (key3),
    .syncOut    (synchronisedkey3)
);

// State-Machine Registers
reg state, nextState;

// Local state name parameters 
localparam PLAY_STATE = 1'b0;  //Game state
localparam MENU_STATE = 1'b1;  //Menu state
  
// State transition logic
always @(key2 or key3 or gameOver) begin
    case (state)
        PLAY_STATE: begin
            reset <= 1'b0;
            clockControl <= clock;
        
            // When menu key is not pressed
            if (!synchronisedkey3) begin 
                nextState <= (key3) ?  state : MENU_STATE;
                reset <= 1'b1;  // Transition to menu state and reset the game
            end
            
        end
        MENU_STATE: begin 
            clockControl <= 1'b0;  // Turn off clock control in menu state

            // When start game button is pressed
            nextState <= (synchronisedkey2) ? state : PLAY_STATE;  // Switch to game state
        end
        default: begin
            state <=  MENU_STATE;  //Default state is menu state
        end
    endcase
end

// State update on the clock rising edge
always @(posedge clock) begin 
    state <= nextState;  //Update current state to the next state
end

endmodule

