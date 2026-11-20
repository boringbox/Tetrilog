// Author: Meilly Chen
// Basic rendering, line clearing, output to VGA
// Adapted from ANIMATION demo

// Bitmaps from: https://github.com/arbiter34/Bitmap-Tetris

module render(CLOCK_50, resetn, block_moved, block_locked, redraw_board, old_x0, old_x1, old_x2, old_x3, old_y0, old_y1, old_y2, old_y3, curr_x0, curr_x1, curr_x2, curr_x3, curr_y0, curr_y1, curr_y2, curr_y3, board_we, board_wdata, board_wx, board_wy, render_state, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK); 

    input CLOCK_50;
    input resetn;

    // go signals
    input block_moved;
    input block_locked;
    input redraw_board;

    // coordinates (10x20 grid)
    // each block is made of 4 squares, so each square needs its own set of coords
    // need old coords as well as current coords to properly erase the block after moving

    input [3:0] old_x0, old_x1, old_x2, old_x3; // 4 bit to hold 0-9
    input [4:0] old_y0, old_y1, old_y2, old_y3; // 5 bit to hold 0-19
    
    input [3:0] curr_x0, curr_x1, curr_x2, curr_x3; // 4 bit to hold 0-9
    input [4:0] curr_y0, curr_y1, curr_y2, curr_y3; // 5 bit to hold 0-19
    
    // board writing
    input board_we; // enable (to update cell)
    input [2:0] board_wdata; // data in grid cell
    // 000 = empty, 001 = colour (other codes will be used for different colours)

    input [3:0] board_wx; // cell coord x
    input [4:0] board_wy; // cell coord y

    output [3:0] render_state; // output signal

    // for the vga adapter
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;

    // Board setup
    parameter COLS = 10, ROWS = 20, CELL = 32;
    parameter X_OFFSET = 10'd160; 
    parameter Y_OFFSET = 9'd0;
    parameter BG = 9'b0; // black bg colour
    parameter GREEN = 9'b000011011; // turquoise ish green?

    // State codes
    parameter S_INIT = 4'd0;
    parameter S_INIT_WAIT = 4'd1;
    parameter S_IDLE = 4'd2;
    parameter S_ERASE = 4'd3;
    parameter S_ERASE_WAIT = 4'd4;
    parameter S_DRAW_ACTIVE = 4'd5;
    parameter S_DRAW_ACTIVE_WAIT = 4'd6;
    parameter S_DRAW_PLACED = 4'd7;
    parameter S_DRAW_PLACED_WAIT = 4'd8;
    parameter S_CLEAR = 4'd9;
    parameter S_CLEAR_WAIT = 4'd10;

    reg [3:0] y_Q, Y_D; // 4 bits to hold all 11 states
    reg [1:0] cellID;
    reg [3:0] gx;
    reg [4:0] gy;
    reg [2:0] board [0:ROWS-1][0:COLS-1]; // starts from LSB for more intuitive iteration (top of the board is 0,0 instead of 4,5)

    reg draw_start, use_mif;
    reg [8:0] solid_colour;
    wire draw_done, write;
    wire [9:0] pix_x;
    wire [8:0] pix_y;
    wire [8:0] vga_colour;

    integer r, c; // rows and columns

    // update the board at the positive clock edge
    always @(posedge CLOCK_50) 
    begin
        if(!resetn) // clear the board
        begin
            for(r = 0; r < ROWS; r = r+1)
                for(c = 0; c <COLS; c=c+1)
                    board[r][c] <= 3'b0; // empty
        end else if (board_we) // write to the cell
            board[board_wy][board_wx] <= board_wdata;
    end

    // State table
    always @(*)
    begin: state_table
        case(y_Q)
            S_INIT: Y_D = S_INIT_WAIT;
            S_INIT_WAIT: Y_D = !draw_done ? S_INIT_WAIT : ((gx == COLS-1 && gy == ROWS-1) ? S_IDLE : S_INIT);
            // stays in wait until draw is done. if draw is done, idles if gx and gy are at the end of the board or continues drawing if not

            S_IDLE: Y_D = redraw_board ? S_CLEAR : (block_locked ? S_DRAW_PLACED : (block_moved ? S_ERASE : S_IDLE));
            // checks for go signals to exit idle state

            S_ERASE: Y_D = S_ERASE_WAIT;
            S_ERASE_WAIT: Y_D = !draw_done ? S_ERASE_WAIT : ((cellID == 2'd3) ? S_DRAW_ACTIVE : S_ERASE);
            
            S_DRAW_ACTIVE: Y_D = S_DRAW_ACTIVE_WAIT;
            S_DRAW_ACTIVE_WAIT: Y_D = !draw_done ? S_DRAW_ACTIVE_WAIT : ((cellID == 2'd3) ? S_IDLE: S_DRAW_ACTIVE);

            S_DRAW_PLACED: Y_D = S_DRAW_PLACED_WAIT;
            S_DRAW_PLACED_WAIT: Y_D = !draw_done ? S_DRAW_PLACED_WAIT : ((cellID == 2'd3) ? S_IDLE : S_DRAW_PLACED);

            S_CLEAR: Y_D = S_CLEAR_WAIT;
            S_CLEAR_WAIT: Y_D = !draw_done ? S_CLEAR_WAIT : ((gx == COLS-1 && gy == ROWS-1) ? S_IDLE : S_CLEAR);

            default: Y_D = S_INIT;
        endcase
    end // state_table

    // Outputs for each state
    always @(*)
    begin: state_actions
        draw_start = 1'b0;
        use_mif = 1'b0;
        solid_colour = BG;

        case(y_Q)
            S_INIT, S_INIT_WAIT:
                draw_start = (y_Q == S_INIT);
            S_ERASE, S_ERASE_WAIT:
                draw_start = (y_Q == S_ERASE);
            S_DRAW_ACTIVE, S_DRAW_ACTIVE_WAIT:
            begin
                solid_colour = GREEN;
                draw_start = (y_Q == S_DRAW_ACTIVE);
            end
            S_DRAW_PLACED, S_DRAW_PLACED_WAIT:
            begin
                solid_colour = GREEN;
                draw_start = (y_Q == S_DRAW_PLACED);
            end
            S_CLEAR, S_CLEAR_WAIT:
            begin
                solid_colour = (board[gy][gx] != 3'b000) ? GREEN : BG;
                draw_start = (y_Q == S_CLEAR);
            end
            default: draw_start = 1'b0; // don't start
        endcase
    end

    reg [3:0] sel_x;
    reg [4:0] sel_y;
    wire use_old = (y_Q == S_ERASE || y_Q == S_ERASE_WAIT);
    always @(*)
    begin
        case(cellID)
            2'd0:
            begin
                sel_x = use_old ? old_x0: curr_x0;
                sel_y = use_old ? old_y0 : curr_y0;
            end
            2'd1:
            begin
                sel_x = use_old ? old_x1: curr_x1;
                sel_y = use_old ? old_y1 : curr_y1;
            end
            2'd2:
            begin
                sel_x = use_old ? old_x2: curr_x2;
                sel_y = use_old ? old_y2 : curr_y2;
            end
            2'd3:
            begin
                sel_x = use_old ? old_x3: curr_x3;
                sel_y = use_old ? old_y3 : curr_y3;
            end
            default: // affect the 4th cellID
            begin
                sel_x = use_old ? old_x3: curr_x3;
                sel_y = use_old ? old_y3 : curr_y3;
            end

        endcase
    end

    // Determine set of coords to use for grid walking based on state
    wire grid_walk = (y_Q == S_INIT  || y_Q == S_INIT_WAIT || y_Q == S_CLEAR || y_Q == S_CLEAR_WAIT);
    wire [3:0] grid_x = grid_walk ? gx : sel_x; // walk the entire grid, or just the cells for the block 
    wire [4:0] grid_y = grid_walk ? gy : sel_y;

    always @(posedge CLOCK_50)
    begin
        if(!resetn) // go back to init and reset grid walk
        begin
            y_Q <= S_INIT; cellID <= 2'd0; gx <= 4'd0; gy <= 5'd0;
        end
        else
        begin
            y_Q <= Y_D;
            if(Y_D == S_IDLE) // if the next state is idle i.e. nothing is happening, also reset cursors
            begin
                cellID <= 2'd0; gx <= 4'd0; gy <= 5'd0;
            end
            else if(draw_done) // if a square is done drawing and the next state isn't idle
            begin
                if((y_Q == S_ERASE_WAIT || y_Q == S_DRAW_ACTIVE_WAIT || y_Q == S_DRAW_PLACED_WAIT))
                    cellID <= cellID + 1'b1; // if we're currently in a drawing waiting state, increment the cellID and prepare for the next draw
                else
                    cellID <= 2'd0; // if we're not waiting, that means all cells are filled, so reset
                if(y_Q == S_INIT_WAIT || y_Q == S_CLEAR_WAIT)
                begin
                    if(gx == COLS -1) // if we've crossed horizontally
                    begin
                        gx <= 4'd0; // go back to the start
                        gy <= (gy == ROWS-1) ? 5'd0 : gy + 1'b1; // put y to the start or go the next row
                    end
                    else
                        gx <= gx + 1'b1; // incremement x
                end
            end
        end
    end

    assign render_state = y_Q; // for checking if rendering is happening currently

    draw_square #(.CELL(CELL), .X_OFFSET(X_OFFSET), .Y_OFFSET(Y_OFFSET)) DRAWER (
        .clock(CLOCK_50), .resetn(resetn), .start(draw_start),
        .grid_x(grid_x), .grid_y(grid_y),
        .use_mif(use_mif), .solid_colour(solid_colour),
        .done(draw_done), .pix_x(pix_x), .pix_y(pix_y),
        .write(write), .vga_colour(vga_colour));

    vga_adapter VGA (
        .resetn(resetn),
        .clock(CLOCK_50),
        .color(vga_colour),
        .x(pix_x),
        .y(pix_y),
        .write(write),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK));

endmodule

module draw_square(clock, resetn, start, grid_x, grid_y, use_mif, solid_colour, done, pix_x, pix_y, write, vga_colour);
    input clock, resetn, start, use_mif;
    input [3:0] grid_x;
    input [4:0] grid_y;
    input [8:0] solid_colour;
    output done;
    output reg [9:0] pix_x; // based on vga adapter
    output reg [8:0] pix_y; // based on vga adapter
    output reg write;
    output [8:0] vga_colour;

    parameter CELL = 32;
    parameter X_OFFSET = 10'd160;
    parameter Y_OFFSET = 9'd0;
    parameter ADDR_W = 10;          // 2^10 = 1024 = 32*32 (bit width of cell)
    parameter DEPTH = CELL * CELL; // square.mif DEPTH

    // FSM for drawing out the pixel
    parameter S_WAIT = 2'd0, S_RUN = 2'd1, S_FLUSH = 2'd2, S_DONE = 2'd3;

    reg [1:0] y_Q, Y_D;
    reg [5:0] Xc, Yc; // pixel inside cell (0 to 31)
    reg [8:0] solid_r;
    wire [ADDR_W-1:0] addr = Yc * CELL + Xc; // index of current pixel
    wire last = (Xc == CELL-1) && (Yc == CELL-1); // flag for if we've reached the last pixel of the cell

    always @(*)
    begin
        case(y_Q)
            S_WAIT: Y_D = start ? S_RUN : S_WAIT;
            S_RUN: Y_D = last ? S_FLUSH : S_RUN;
            S_FLUSH: Y_D = S_DONE;
            S_DONE: Y_D = S_WAIT;
            default: Y_D = S_WAIT;
        endcase
    end

    always @(posedge clock) 
    begin
        if(!resetn)
        begin
            y_Q <= S_WAIT;
            Xc <= 6'd0; Yc <= 6'd0;
            pix_x <= 10'd0; pix_y <= 9'd0;
            write <= 1'b0; solid_r <= 9'd0;
        end
        else
        begin
            y_Q <= Y_D;
            pix_x <= X_OFFSET + (grid_x * CELL) + Xc;
            pix_y <= Y_OFFSET + (grid_y * CELL) + Yc;
            write <= (y_Q == S_RUN);
            solid_r <= solid_colour;
            if(y_Q == S_WAIT || y_Q == S_DONE)
            begin
                Xc <= 6'd0;
                Yc <= 6'd0;
            end
            else if(y_Q == S_RUN && !last)
            begin
                if(Xc == CELL-1)
                begin
                    Xc <= 6'd0;
                    Yc <= Yc + 1'b1;
                end
                else
                    Xc <= Xc + 1'b1;
            end
        end
    end

    assign vga_colour = solid_r;
    assign done = (y_Q == S_DONE);

endmodule