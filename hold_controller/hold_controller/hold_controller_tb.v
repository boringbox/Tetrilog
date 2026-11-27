
//Testing 2 scenarios:
// 1. First hold -> save current piece and load new one
// 2. Swap -> after current piece locks, hold again, and get the previously saved piece

//initially, next_piece_id = 4 (J)
//hold controller requests for another piece
//generator changes it to 5 (L)

`timescale 1ns/1ps

module hold_controller_tb;

    reg Clock;
    reg Resetn;
    reg hold_request;
    reg piece_locked;

    reg [2:0] current_piece_id;
    reg [2:0] next_piece_id;

    wire [2:0] piece_to_load;
    wire load_piece;
    wire request_next_piece;
    wire [2:0] held_piece_id;
    wire hold_valid;
    wire hold_used;

    // Generate clock
    initial Clock = 1'b0;
    always #5 Clock = ~Clock;

    // Connect hold controller
    hold_controller DUT (
        .Clock(Clock),
        .Resetn(Resetn),
        .hold_request(hold_request),
        .piece_locked(piece_locked),
        .current_piece_id(current_piece_id),
        .next_piece_id(next_piece_id),
        .piece_to_load(piece_to_load),
        .load_piece(load_piece),
        .request_next_piece(request_next_piece),
        .held_piece_id(held_piece_id),
        .hold_valid(hold_valid),
        .hold_used(hold_used)
    );

    // Simple fake piece generator because actual project has a random piece generator
    //hold controller sends it a signal called "request_next_piece" and generator
    //supplies a new piece.
    //this fake generator changes the piece ID whenever it recieves request_next_piece
    always @(posedge Clock) begin
        if (request_next_piece) begin
            if (next_piece_id == 3'd7)
                next_piece_id <= 3'd1;
            else
                next_piece_id <= next_piece_id + 3'd1;
        end
    end

    initial begin

        // Initial values
        Resetn = 1'b0;
        hold_request = 1'b0;
        piece_locked = 1'b0;

        current_piece_id = 3'd3; // T piece
        next_piece_id = 3'd4;    // J piece

        // Reset
        repeat (2) @(posedge Clock);
        #1;
        Resetn = 1'b1;

        // TEST 1: First hold
        @(posedge Clock);
        #1;
        hold_request = 1'b1;

        @(posedge Clock);
        #1;
        hold_request = 1'b0;

        // Wait for hold FSM to finish
        repeat (2) @(posedge Clock);
        #1;

        $display("TEST 1: First hold");
        $display("Held piece = %d", held_piece_id);
        $display("Piece to load = %d", piece_to_load);
        $display("Hold valid = %b", hold_valid);
        $display("Load piece = %b", load_piece);

        // Update current piece to newly loaded piece
        current_piece_id = piece_to_load;

        // TEST 2: Try holding again before locking
        @(posedge Clock);
        #1;
        hold_request = 1'b1;

        @(posedge Clock);
        #1;
        hold_request = 1'b0;

        $display("TEST 2: Hold before locking");
        $display("Load piece = %b", load_piece);
        $display("Hold used = %b", hold_used);

        // TEST 3: Lock current piece
        @(posedge Clock);
        #1;
        piece_locked = 1'b1;

        @(posedge Clock);
        #1;
        piece_locked = 1'b0;

        // TEST 4: Hold again after locking
        hold_request = 1'b1;

        @(posedge Clock);
        #1;
        hold_request = 1'b0;

        // Wait for hold FSM to finish
        repeat (2) @(posedge Clock);
        #1;

        $display("TEST 3: Swap after locking");
        $display("Held piece = %d", held_piece_id);
        $display("Piece to load = %d", piece_to_load);
        $display("Load piece = %b", load_piece);
        $display("Hold used = %b", hold_used);

        repeat (2) @(posedge Clock);

        $finish;

    end

endmodule
