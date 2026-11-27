
//This module will be in charge of holding a piece
//For example, if you have a L piece and you press the hold key
//The L piece is stored in the hold slot and the game will request
//a new piece from the generator. That new piece will then become active
//Later, if you press hold again, the current piece goes into the hold slot
//and the previously stored L becomes active
//YOU CAN ONLY HOLD ONCE PER PIECE. Meaning you have to wait until the next piece
//is locked in place before holding again

module hold_controller (

    input Clock,
    input Resetn, //when it's zero, module resets

    input hold_request, //one-clock cycle signal indicating player pressed hold
    input piece_locked, //tells controller that active piece has landed & locked

    input [2:0] current_piece_id, //ID of piece currently being controlled by MoveBlock
    input [2:0] next_piece_id, //block generator's current output

    output reg [2:0] piece_to_load, //ID of piece that should be active
    output reg load_piece, //tells rest of the game to load "piece_to_load"
    output reg request_next_piece, //tells generator to advance
    output reg [2:0] held_piece_id, //stores held piece ID
    output reg hold_valid, //indicates whether hold slot already contains a piece
    output reg hold_used //prevents player from holding AGAIN during the SAME piece's turn
);

  parameter IDLE = 2'd0, //wait for player to press hold
            WAIT_NEXT_PIECE = 2'd1, //wait for generator to produce next piece
            LOAD_NEXT_PIECE = 2'd2; //load the newly generated piece

  reg [1:0] state;


  always @(posedge Clock) begin

        if (!Resetn) begin

            state <= IDLE;

            piece_to_load <= 3'd0;
            load_piece <= 1'b0;
            request_next_piece <= 1'b0;

            held_piece_id <= 3'd0;
            hold_valid <= 1'b0;
            hold_used <= 1'b0;

        end

        else begin

            //Default: output pulses are inactive
            load_piece <= 1'b0;
            request_next_piece <= 1'b0;

            //a locked piece will allow for holding again
            if (piece_locked)
                hold_used <= 1'b0;

            case (state)

                IDLE: begin

                    if (hold_request && !hold_used &&
                        current_piece_id != 3'd0) begin

                        //save the current piece
                        held_piece_id <= current_piece_id;

                        if (!hold_valid) begin

                            //no piece was held before
                            //requesting a new piece from the generator
                            hold_valid <= 1'b1;
                            request_next_piece <= 1'b1;

                            state <= WAIT_NEXT_PIECE;

                        end

                        else begin

                            //a piece was already held
                            //load the previously held piece
                            piece_to_load <= held_piece_id;
                            load_piece <= 1'b1;

                            hold_used <= 1'b1;

                        end

                    end

                end


                WAIT_NEXT_PIECE: begin

                    //wait for synchronous generator to update its piece output
                    state <= LOAD_NEXT_PIECE;

                end


                LOAD_NEXT_PIECE: begin

                    //new generated piece is available now

                    piece_to_load <= next_piece_id;
                    load_piece <= 1'b1;

                    hold_used <= 1'b1;
                    state <= IDLE;

                end


                default: begin

                    state <= IDLE;

                end

            endcase

        end

    end

endmodule

