// Author: Meilly Chen
// Basic rendering, line clearing, output to VGA
// Adapted from ANIMATION demo

// Bitmaps from: https://github.com/arbiter34/Bitmap-Tetris

module render(CLOCK_50, resetn, block_moved, block_locked, redraw_board, old_x0, old_x1, old_x2, old_x3, old_y0, old_y1, old_y2, old_y3, curr_x0, curr_x1, curr_x2, curr_x3, curr_y0, curr_y1, curr_y2, curr_y3, board_we, board_wdata, board_wx, board_wy, render_idle, VGA_R, VGA_G, VGA_B,
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

    output render_idle; // output signal for checking state

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
    parameter GREEN = 9'b000111001; // turquoise ish green?

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
    reg inc_cell, step_grid, clear_cursors;
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

    // FSM outputs. state drives the VGA signals
    always @(*)
    begin: state_actions
        draw_start = 1'b0;
        use_mif = 1'b0;
        solid_colour = BG;
        inc_cell = 1'b0;
        step_grid = 1'b0;
        clear_cursors = (Y_D == S_IDLE);

        case (y_Q)
            S_INIT:
                draw_start = 1'b1;
            S_ERASE:
                draw_start = 1'b1;
            S_DRAW_ACTIVE, S_DRAW_PLACED:
            begin
                solid_colour = GREEN;
                draw_start = 1'b1;
            end
            S_CLEAR:
            begin
                solid_colour = (board[gy][gx] != 3'b000) ? GREEN : BG;
                draw_start = 1'b1;
            end
            S_ERASE_WAIT:
					inc_cell = draw_done && (Y_D != S_IDLE);
				S_DRAW_ACTIVE_WAIT, S_DRAW_PLACED_WAIT:
				begin
                solid_colour = GREEN;
					 inc_cell = draw_done && (Y_D != S_IDLE);
				end
            S_INIT_WAIT, S_CLEAR_WAIT:
                step_grid = draw_done && (Y_D != S_IDLE);
        endcase
    end

    // state ffs
    always @(posedge CLOCK_50)
    begin
        if(!resetn)
            y_Q <= S_INIT;
        else
            y_Q <= Y_D;
    end
    
    // FSM Output
    assign render_idle = (y_Q == S_IDLE); // for checking idle state
    

    // grid cursor update
    always @(posedge CLOCK_50)
    begin
        if (!resetn || clear_cursors)
        begin
            cellID <= 2'd0;
            gx <= 4'd0;
            gy <= 5'd0;
        end
        else if (inc_cell)
            cellID <= cellID + 1'b1;
        else if (step_grid)
        begin
            cellID <= 2'd0;
            if (gx == COLS-1)
            begin
                gx <= 4'd0;
                gy <= gy + 1'b1;
            end
            else
                gx <= gx + 1'b1;
        end
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
    output [9:0] pix_x; // based on vga adapter
    output [8:0] pix_y; // based on vga adapter
    output reg write;
    output [8:0] vga_colour;

    parameter CELL = 32;
    parameter X_OFFSET = 10'd160;
    parameter Y_OFFSET = 9'd0;
    parameter ADDR_W = 10;          // 2^10 = 1024 = 32*32 (bit width of cell)
    parameter DEPTH = CELL * CELL; // square.mif DEPTH

   parameter S_WAIT = 2'b00, S_X = 2'b01, S_Y = 2'b10, S_DONE = 2'b11;

    reg [1:0] y_Q, Y_D;
    reg [5:0] Xc, Yc;
    reg Lxc, Lyc, Exc, Eyc;

    always @(*)
        case (y_Q)
            S_WAIT: Y_D = start ? S_X : S_WAIT;
            S_X:    Y_D = (Xc != CELL-1) ? S_X : S_Y;
            S_Y:    Y_D = (Yc != CELL-1) ? S_X : S_DONE;
            S_DONE: Y_D = S_WAIT;
            default: Y_D = S_WAIT;
        endcase

    always @(*)
    begin
        Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0; write = 1'b0;
        case (y_Q)
            S_WAIT: begin Lxc = 1'b1; Lyc = 1'b1; end   // hold counters at 0
            S_X:    begin Exc = 1'b1; write = 1'b1; end // write this pixel, step X
            S_Y:    begin Lxc = 1'b1; Eyc = 1'b1; end   // reload X, step Y
            S_DONE: begin Lxc = 1'b1; Lyc = 1'b1; end   // reload both; write stays 0
        endcase
    end

    always @(posedge clock)
        if (!resetn)
            y_Q <= S_WAIT;
        else
            y_Q <= Y_D;

    always @(posedge clock)
        if (!resetn)        Xc <= 6'd0;
        else if (Lxc)       Xc <= 6'd0;
        else if (Exc)       Xc <= Xc + 1'b1;

    always @(posedge clock)
        if (!resetn)        Yc <= 6'd0;
        else if (Lyc)       Yc <= 6'd0;
        else if (Eyc)       Yc <= Yc + 1'b1;

    assign pix_x = X_OFFSET + (grid_x * CELL) + Xc;
    assign pix_y = Y_OFFSET + (grid_y * CELL) + Yc;
    assign vga_colour = solid_colour;
    assign done = (y_Q == S_DONE);
    
endmodule