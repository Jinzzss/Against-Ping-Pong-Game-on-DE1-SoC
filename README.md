# ELEC5566M Mini-Project Repository
This is a racket sports game programmed in Verilog for the DE1-Soc board, the software we used is Quartus Prime Lite 22.1, and the game improves the LT24 display performance. The small ball randomly appears from the bottom, and a player can control a paddle, and another paddle is set to automatically move like an AI controls it . This project satisfies all of the minimum requirements and most of the further requirements.

The following files are provided:

| File | Purpose |
| ---  |  ---  |
|  `MoveBall.v`  | This module is designed to change the ball position and achieve high-speed and precise control of the ball, letting the ball move through the whole LT24 screen， and the ball bounce when it hit the paddle or the boundaries of the screen.
| `MoveBall_tb.v` | This module is a testbench to test the module Ball.
| `BallGame.v` | This module is responsible for implementing the core functionalities of the game and managing main states of the game. It also handles driving display devices.
| `BinaryToBCD.v` | This module's function is mainly to convert binary numbers into Binary Coded Decimal(BCD).
| `BinaryToBCD_tb.v` | This is a testbench to test the BinaryToBCD module.
| `CounterNBit.v` | This module is a configurable N bit counter, mainly used to generate a counting sequence within a fixed range.
| `CounterNBit_tb.v` | This is a testbench for the CounterNBit module.
| `Debouncer.v` | This module mainly aims to eliminate burrs and oscillations of asynchronous input signals which could improve the stability and reliability of the system. It uses a parametric design to adapt to different application needs.
| `Debouncer_tb.v` | This is a testbench for testing the Debouncer module to ensure the module can correctly and stably and synchronously input signals.
| `GameEngine.v` | This is a complete game engine for controlling and managing a paddle and ball based video game. This module integrates multiple sub-modules and components. It makes use of the LT24Display IP core, and it allow images to be displayed on the LT24 screen.
| `HexTo7Segment.v` | This module converts a 4-bit binary encoded hexadecimal number (hex) into the 7-bit control signal (seg) required for a seven-segment display.
| `HexTo7Segment_tb.v` | This is a test bench module to test the HexTo7Segment Module. 
| ` LT24Display.sdc.v` |  This module is a timing constraint file used in FPGA design. It tells the compilation tools how to optimize the design to meet specific performance requirements. It is crucial in the FPGA design because it ensures that the design works safely and reliably within predetermined physical parameters to avoid functional failures caused by clock desynchronization and other issues.
| `LT24Display.v` | This module is used to drive the LT24 display and is designed to provide full functionality for interfacing with the Terasic LT24 display so that we can initialize the display and write pixel data to its internal frame buffer. 
| `MovePaddle.v`| This module is responsible for changing the paddle position and letting it move up and down in the whole screen to catch the ball. There are two paddles, one of them is designed to be moved automatically because we assume it is controlled by the AI, and another one could be controlled by players by using specified buttons on the DE1-Soc board.
| `MovePaddle_tb.v` | This is a testbench of the module MovePaddle to test whether the paddle could be manipulated to move by players by using buttons, and it tests the module to let the paddles not move out of the screen.
|`RefreshRate.v` |The module is mainly used to generate a refresh control signal of a specific frequency. It uses an internal counter ( The CounterNBit module) to generate a periodically toggled output signal. 
| `RefreshRate_tb.v` | This is a test bench module to test the RefreshRate Module.
| ` UpCounterNbit` | This module is mainly used to count the input signal at a given clock signal unit it reaches the specified maximum value and then resets to zero.
| `set_LCD_pin_locs.tcl` | Script to automatically assign hardware pins.