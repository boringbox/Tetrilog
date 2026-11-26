`timescale 1ns / 1ns
`default_nettype none

module testbench ( );
    reg CLOCK_50 = 1'b0;
    reg Resetn = 1'b0;
    reg NextBlock = 1'b0;
    wire [2:0] Piece;

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        #20  Resetn = 1'b1; // release reset, Piece = I, LFSR seed = ECE0
        // ECE0: We should see 1 because resetn forces this to be at PIECE_I

		// NextBlock is high for 20 ns; Piece changes on the clock edge inside that pulse
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: D9C0 4
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 6702 2
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 9C0A 5
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 702B 2
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: C0AE 5
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 02BA 6
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 0AEA 2
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 2BAB 1 
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: AEAE 3

        #20  Resetn = 1'b0;                             // Expected: ECE0 1
        #40  Resetn = 1'b1; 

        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: D9C0 4
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 6702 2
		#20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 9C0A 5
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Expected: 702B 2

        // Only reads when NextBlock == 1, 

    end

    Randomiser U1 (CLOCK_50, Resetn, NextBlock, Piece);
endmodule

`default_nettype wire