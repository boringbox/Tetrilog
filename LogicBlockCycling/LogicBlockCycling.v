/*
Code: https://en.wikipedia.org/wiki/Tetromino
Piece[1] = I block 
Piece[2] = O Block
Piece[3] = T Block
Piece[4] = J Block
Piece[5] = L Block
Piece[6] = S Block
Piece[7] = Z Block 
*/ 

module LogicBlockCycling(Clock, Resetn, NextBlock, Piece);
    parameter [2:0] PIECE_I = 3'd1; 
    parameter [2:0] PIECE_O = 3'd2;
    parameter [2:0] PIECE_T = 3'd3;
    parameter [2:0] PIECE_J = 3'd4;
    parameter [2:0] PIECE_L = 3'd5;
    parameter [2:0] PIECE_S = 3'd6;
    parameter [2:0] PIECE_Z = 3'd7;

    input Clock;
    input Resetn;          
    input NextBlock;       // 1-clock pulse: step to the next piece
    output reg [2:0] Piece;

    always @(posedge Clock)
    begin
        if (Resetn == 1'b0)
            Piece <= PIECE_I;
        else if (NextBlock == 1'b1)
        begin
            if (Piece == PIECE_Z)
                Piece <= PIECE_I;
            else
                Piece <= Piece + 1'b1;
        end
    end
endmodule
