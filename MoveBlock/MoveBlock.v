
/* 
States: 
IDLE - Do nothing 
RECEIVE - Check whether move is legal, if yes update px and py 
PLOT - Send signal to render module to do the move
old x and y - to erase on render module
curr x and y - to draw on render module 
new x and y - to check whether this move is valid to check with collision module 

*/

module MoveBlock(Clock, Resetn, cmd_in, cmd_valid, Piece, spawn, done,  
    curr_x0, curr_x1, curr_x2, curr_x3, curr_y0, curr_y1, curr_y2, curr_y3,
    old_x0,  old_x1,  old_x2,  old_x3,  old_y0,  old_y1,  old_y2,  old_y3,
    new_x0, new_x1, new_x2, new_x3, new_y0, new_y1, new_y2, new_y3, 
    block_moved, render_idle, blocked); 

    // cmd_in from PlayerDecoder, tells us whether its move down, left or right
    // cmd_valid one clock cycle of the command being passed in
    input Clock, Resetn, cmd_valid;
    input [2:0] cmd_in; 
    input [2:0] Piece; 
    input spawn, render_idle, blocked;

    output done; 
    output block_moved, busy; 
    output [3:0] curr_x0, curr_x1, curr_x2, curr_x3, old_x0, old_x1, old_x2, old_x3,
                 new_x0, new_x1, new_x2, new_x3;
    output [4:0] curr_y0, curr_y1, curr_y2, curr_y3, old_y0, old_y1, old_y2, old_y3,
                 new_y0, new_y1, new_y2, new_y3;

    // States
    parameter [2:0] IDLE = 3'b001;
    parameter [2:0] RECEIVE = 3'b010;
    parameter [2:0] PLOT = 3'b100;

    // Commands from decoder
    parameter [2:0] CMD_NONE  = 3'b000;
    parameter [2:0] CMD_LEFT  = 3'b001;
    parameter [2:0] CMD_RIGHT = 3'b010;
    parameter [2:0] CMD_DOWN  = 3'b011;

    // Pieces (Valid for both block cycler and LFSR)
    parameter [2:0] PIECE_I = 3'd1; 
    parameter [2:0] PIECE_O = 3'd2;
    parameter [2:0] PIECE_T = 3'd3;
    parameter [2:0] PIECE_J = 3'd4;
    parameter [2:0] PIECE_L = 3'd5;
    parameter [2:0] PIECE_S = 3'd6;
    parameter [2:0] PIECE_Z = 3'd7;

    // I think using a reference coordinate would make life easier, 
    // Spawn anchor: (10 - 4) / 2 = 3 centres the 4x4 box; row 0 = top
    parameter [3:0] SPAWN_X = 4'd3;
    parameter [4:0] SPAWN_Y = 5'd0;
    
    reg [2:0] y_Q; // Current State
    reg [2:0] Y_D; // Next State
    reg [2:0] cmd;              // saved command
    reg [2:0] shape;            // saved piece type
    reg [3:0] px, ox, cx;       // anchor column: current, old, candidate
    reg [4:0] py, oy, cy;       // anchor row:    current, old, candidate
    reg sent;      // render has accepted block_moved
   


    // FSM Combinational
    // cases: 
    always @(*)
    begin: state_table
        case(y_Q)
            IDLE: 
            begin 
                if (spawn) // If generate new block
                    Y_D = PLOT;
                else if (cmd_valid)
                    Y_D = RECEIVE;
                else 
                    Y_D = IDLE; 
            end 

            RECEIVE:
            begin 
                if (is_move && !blocked)
                Y_D = PLOT;
                else
                Y_D = IDLE;
            end

            PLOT:
            begin
            if (sent && render_idle)
                Y_D = IDLE;
            else
                Y_D = PLOT;
            end

            default: Y_D = IDLE; 
        endcase
    end

    // FSM Sequential 
    always@(posedge Clock)
    begin: state_FFs
        if(!Resetn)
            y_Q <= IDLE;
        else 
            y_Q <= Y_D;
    end

    always @(posedge Clock)
    begin
        if (!Resetn)
        begin
            cmd <= 3'd0;  shape <= 3'd0;
            px <= SPAWN_X;  py <= SPAWN_Y;
            ox <= SPAWN_X;  oy <= SPAWN_Y;
        end
        else if (y_Q == IDLE && spawn)
        begin
            shape <= piece;                          // new piece at the top
            px <= SPAWN_X;  py <= SPAWN_Y;
            ox <= SPAWN_X;  oy <= SPAWN_Y;           // old = curr: nothing to erase
        end
        else if (y_Q == IDLE && cmd_valid)
            cmd <= cmd_in;                           // save the command
        else if (y_Q == RECEIVE && is_move && !blocked)
        begin
            ox <= px;  oy <= py;                     // remember where we were
            px <= cx;  py <= cy;                     // move
        end
    end

    always @(posedge Clock)
        if (!Resetn || y_Q != PLOT) sent <= 1'b0;
        else if (render_idle)       sent <= 1'b1;
 
        assign block_moved = (y_Q == PLOT) && !sent;
        assign busy        = (y_Q != IDLE);

endmodule