// DE1-SoC top level for a solid-colour render test.
module top(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
           VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

    input CLOCK_50;
    input [9:0] SW;
    input [3:0] KEY;
    output [9:0] LEDR;
    output [7:0] VGA_R, VGA_G, VGA_B;
    output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

    wire render_idle;

    assign LEDR[0] = render_idle;
    assign LEDR[9:1] = 9'b0;

    render U1 (
        .CLOCK_50(CLOCK_50),
        .resetn(KEY[0]),
        .block_moved(1'b0),
        .block_locked(~KEY[1]),
        .redraw_board(1'b0),

        .old_x0(4'd4), .old_x1(4'd3), .old_x2(4'd4), .old_x3(4'd5),
        .old_y0(5'd0), .old_y1(5'd1), .old_y2(5'd1), .old_y3(5'd1),
        .curr_x0(4'd4), .curr_x1(4'd3), .curr_x2(4'd4), .curr_x3(4'd5),
        .curr_y0(5'd0), .curr_y1(5'd1), .curr_y2(5'd1), .curr_y3(5'd1),

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
endmodule