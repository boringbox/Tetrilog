
//testing 2 cases:
// Level 0 -> slower gravity (20 cycles)
//Level 2 -> faster gravity (10 cycles = 20 - (2 x 5))

`timescale 1ns/1ps

module gravity_controller_tb;

    reg CLOCK_50;
    reg Resetn;
    reg game_active;
    reg [3:0] level;

    wire gravity_counter;

    // Generate clock
    initial CLOCK_50 = 1'b0;
    always #5 CLOCK_50 = ~CLOCK_50;

    // Connect gravity controller with smaller test intervals
    gravity_controller #(
        .BASE_INTERVAL(20),
        .STEP_INTERVAL(5),
        .MIN_INTERVAL(5)
    ) DUT (
        .CLOCK_50(CLOCK_50),
        .Resetn(Resetn),
        .game_active(game_active),
        .level(level),
        .gravity_counter(gravity_counter)
    );

    initial begin

        // Initial values
        Resetn = 1'b0;
        game_active = 1'b0;
        level = 4'd0;

        // Reset
        repeat (2) @(posedge CLOCK_50);
        #1;
        Resetn = 1'b1;

        // TEST 1: Level 0
        @(posedge CLOCK_50);
        #1;
        game_active = 1'b1;
        level = 4'd0;

        repeat (45) @(posedge CLOCK_50);

        // Stop game to reset counter
        #1;
        game_active = 1'b0;

        repeat (2) @(posedge CLOCK_50);
        #1;

        // TEST 2: Level 2
        level = 4'd2;
        game_active = 1'b1;

        repeat (25) @(posedge CLOCK_50);

        $finish;

    end

endmodule
