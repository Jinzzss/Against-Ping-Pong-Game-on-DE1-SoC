

/*  BinaryToBCD
 *---------------------------
 * By: Jingyu Liu
 * For: University of Leeds
 * Date: 28th April 2024 
 *
 * Short Description
 * -----------------
 *This module converts binary numbers into binary coded decimal.
 * Reference: Benjamin Evans - Elec5566 Fpga Design - BinaryToBCD.v
 */ 

module BinaryToBCD(
    bin,
    bcd
    );

    // Input port and size definitions
    input [7:0] bin;
    // Output port and size definitions
    output reg [11:0] bcd;

    // Internal variable definition
    integer i;   // Use integer to define loop variables because it has little impact on performance and is easier to read.
   
    // Main logic block - using Double Dabble algorithm
    always @(bin) begin
        bcd = 12'd0; // Initialize BCD to zero
		  
        // Execute a loop for each bit of input
        for (i = 0; i < 8; i = i + 1) begin
            bcd = {bcd[10:0], bin[7-i]}; // Shift the BCD register left by one bit and merge the corresponding bits of bin into
            
            // If any group of four digits in BCD is greater than 4, add 3
            if (i < 7) begin
                if (bcd[3:0] > 4)
                    bcd[3:0] = bcd[3:0] + 3;
                if (bcd[7:4] > 4)
                    bcd[7:4] = bcd[7:4] + 3;
                if (bcd[11:8] > 4)
                    bcd[11:8] = bcd[11:8] + 3;
            end
        end
    end

endmodule
