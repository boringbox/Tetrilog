`timescale 1ns/1ps

module testbench();
    reg CLOCK_50;
    reg [9:0] SW;
    reg [3:0] KEY;
    wire [9:0] LEDR;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    top DUT (
        .CLOCK_50(CLOCK_50),
        .SW(SW),
        .KEY(KEY),
        .LEDR(LEDR),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    always #10 CLOCK_50 = ~CLOCK_50; // generate periodic clock waveform

    initial 
    begin
        SW = 10'b0;
        KEY = 4'b0000;
        
        CLOCK_50 <= 1'b0;
        KEY[0] <= 1'b0; // reset

        #20 SW[0] <= 1'b1; // trigger block_moved
        #20 SW[0] <= 1'b0;

        #20 SW[1] <= 1'b1; // trigger block_locked (place block)
        #20 SW[1] <= 1'b0;

        #20 SW[2] <= 1'b1; // trigger redraw_board   
        #20 SW[2] <= 1'b0;

        #20 KEY[0] <= 1'b0; // reset again

    
    end
endmodule