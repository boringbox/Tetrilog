`timescale 1ns / 1ns
`default_nettype none

module testbench ( );
    reg CLOCK_50 = 1'b0;
    reg Resetn = 1'b0;
    reg NextBlock = 1'b0;
    wire [2:0] Piece;

    always #10 CLOCK_50 = ~CLOCK_50;

    initial begin
        #20  Resetn = 1'b1; // release reset

        // 1 full cycle all 7 blocks
		// What should be expected: Signal for on 20 ns, before off, but next clock cycle, there should be a change in Piece; 
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  O 
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  T
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  J
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  L
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  S
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  Z
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  I

        // Cycle twice, then reset
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  O
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  T
        #20  Resetn = 1'b0;                             //  I
        #40  Resetn = 1'b1; // Test how long it keeps at I, since this is the reset state (default I)

        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  O
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  T
		#20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  J
        #20  NextBlock = 1'b1;  #20 NextBlock = 1'b0;   //  L
    end

    LogicBlockCycling U1 (CLOCK_50, Resetn, NextBlock, Piece);
endmodule

`default_nettype wire