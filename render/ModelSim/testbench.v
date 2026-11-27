`timescale 1ns/1ps

// One operation at a time, with idle in between:
//   reset -> INIT / INIT_WAIT across the board -> IDLE
//   block_moved  -> ERASE / ERASE_WAIT, then DRAW_ACTIVE / DRAW_ACTIVE_WAIT -> IDLE
//   block_locked -> DRAW_PLACED / DRAW_PLACED_WAIT -> IDLE
//   redraw_board -> CLEAR / CLEAR_WAIT across the board -> IDLE
//
// CELL is 1 here so each square is a single pixel (for clarity). The FPGA build still uses 32.

module testbench();
    reg CLOCK_50;
    reg resetn;
    reg block_moved, block_locked, redraw_board;
    wire render_idle;
    wire [7:0] VGA_R, VGA_G, VGA_B;
    wire VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    render #(.CELL(1)) DUT (
        .CLOCK_50(CLOCK_50),
        .resetn(resetn),
        .block_moved(block_moved),
        .block_locked(block_locked),
        .redraw_board(redraw_board),
        .old_x0(4'd4), .old_x1(4'd3), .old_x2(4'd4), .old_x3(4'd5),
        .old_y0(5'd0), .old_y1(5'd1), .old_y2(5'd1), .old_y3(5'd1),
        .curr_x0(4'd4), .curr_x1(4'd3), .curr_x2(4'd4), .curr_x3(4'd5),
        .curr_y0(5'd1), .curr_y1(5'd2), .curr_y2(5'd3), .curr_y3(5'd4),
        .board_we(1'b0),
        .board_wdata(3'b000),
        .board_wx(4'd0),
        .board_wy(5'd0),
        .render_idle(render_idle),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_CLK(VGA_CLK)
    );

    initial CLOCK_50 = 1'b0;
    always #10 CLOCK_50 = ~CLOCK_50;

    // Go high for one clock while idle, then wait until the operation finishes.
    task pulse;
        input integer go_id; // 0 move, 1 lock, 2 redraw
        begin
            @(posedge CLOCK_50); #1;
            block_moved  = (go_id == 0);
            block_locked = (go_id == 1);
            redraw_board = (go_id == 2);
            @(posedge CLOCK_50); #1;
            block_moved  = 1'b0;
            block_locked = 1'b0;
            redraw_board = 1'b0;
            while (render_idle == 1'b1) begin
                @(posedge CLOCK_50); #1;
            end
            while (render_idle == 1'b0) begin
                @(posedge CLOCK_50); #1;
            end
        end
    endtask

    initial begin
        resetn = 1'b0;
        block_moved = 1'b0;
        block_locked = 1'b0;
        redraw_board = 1'b0;

        repeat (3) @(posedge CLOCK_50); #1;
        resetn = 1'b1;

        while (render_idle == 1'b0) begin
            @(posedge CLOCK_50); #1;
        end

        pulse(0);

        pulse(1);

        pulse(2);

    end
endmodule
