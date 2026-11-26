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

    // 50 MHz clock -> each clock cycle is 20ns
    initial CLOCK_50 = 1'b0;
    always #10 CLOCK_50 = ~CLOCK_50;

    // check for timeout
    initial begin
        #20_000_000;
        $display("TIMEOUT at %0t: render_idle did not return", $time);
        $stop;
    end

    // Assert one go switch for two clocks, then wait until render is idle again.
    // LEDR[0] is render_idle. The switch must already be low before idle returns,
    // otherwise S_IDLE starts the same operation again.
    task pulse_sw;
        input integer idx;
        begin
            @(posedge CLOCK_50);
            SW[idx] = 1'b1;
            repeat (2) @(posedge CLOCK_50);
            SW[idx] = 1'b0;
            @(posedge LEDR[0]);
        end
    endtask

    initial begin
        SW = 10'b0;
        KEY = 4'b1111;

        #20 KEY[0] = 1'b0; // trigger resetn

        repeat (5) @(posedge CLOCK_50);
        KEY[0] = 1'b1;

        // S_INIT clears the board before the first idle
        @(posedge LEDR[0]);

        pulse_sw(0); // block_moved: erase, then draw the active piece

        pulse_sw(1); // block_locked: draw the placed piece

        pulse_sw(2); // redraw_board: repaint every cell

        $stop;
    end
endmodule
