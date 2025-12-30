
/*  BinaryToBCD_tb
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 *This module is a testbench to test BinaryToBCD module
 * Reference: Benjamin Evans - Elec5566 Fpga Design - BinaryToBCD.v
 */ 




module BinaryToBCD_tb;

    // input port
    reg [7:0] bin;
    // Output port
    wire [11:0] bcd;
    // Extra variables for loop iteration
    reg [8:0] i;

    // Instantiate the unit under test (UUT)
    BinaryToBCD BinaryToBCD_dut (
        .bin(bin), 
        .bcd(bcd)
    );

    // Simulation - Application Input
    initial begin
        // Use a loop to check all input combinations
        for(i = 0; i < 256; i = i + 1)
        begin
            bin = i;  // Assign the value of i to bin
            #10; // Waiting outputs
        end 
        $finish; // System function to stop the simulation
    end
      
endmodule
