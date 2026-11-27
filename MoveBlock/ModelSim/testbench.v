`timescale 1ns/ 1ps

module testbench();

    reg Clock = 1'b0;
    reg Resetn = 1'b0;
    reg cmd_valid = 1'b0;
    reg spawn = 1'b0;
    reg render_idle = 1'b1;
    reg blocked = 1'b0;
    reg [2:0] cmd_in = 3'b000;
    reg [2:0] piece = 3'b000;

    wire done, block_moved, busy;
    wire [3:0] curr_x0, curr_x1, curr_x2, curr_x3;
    wire [3:0] old_x0,  old_x1,  old_x2,  old_x3;
    wire [3:0] new_x0,  new_x1,  new_x2,  new_x3;
    wire [4:0] curr_y0, curr_y1, curr_y2, curr_y3;
    wire [4:0] old_y0,  old_y1,  old_y2,  old_y3;
    wire [4:0] new_y0,  new_y1,  new_y2,  new_y3;

    localparam [2:0] CMD_LEFT  = 3'b001;
    localparam [2:0] CMD_RIGHT = 3'b010;
    localparam [2:0] CMD_DOWN  = 3'b011;
    localparam [2:0] PIECE_I   = 3'd1;
    localparam [2:0] PIECE_O   = 3'd2;

    integer errors;
    reg [2:0] tb_piece;
    reg [3:0] anchor_x;
    reg [4:0] anchor_y;

    // Clock
    always #10 Clock = ~Clock;

    MoveBlock DUT(
        .Clock(Clock), .Resetn(Resetn), .cmd_in(cmd_in), .cmd_valid(cmd_valid),
        .piece(piece), .spawn(spawn), .done(done),
        .curr_x0(curr_x0), .curr_x1(curr_x1), .curr_x2(curr_x2), .curr_x3(curr_x3),
        .curr_y0(curr_y0), .curr_y1(curr_y1), .curr_y2(curr_y2), .curr_y3(curr_y3),
        .old_x0(old_x0), .old_x1(old_x1), .old_x2(old_x2), .old_x3(old_x3),
        .old_y0(old_y0), .old_y1(old_y1), .old_y2(old_y2), .old_y3(old_y3),
        .new_x0(new_x0), .new_x1(new_x1), .new_x2(new_x2), .new_x3(new_x3),
        .new_y0(new_y0), .new_y1(new_y1), .new_y2(new_y2), .new_y3(new_y3),
        .block_moved(block_moved), .render_idle(render_idle),
        .blocked(blocked), .busy(busy)
    );

    task do_render;
        begin
            @(posedge Clock); #1;
            render_idle = 1'b0;
            @(posedge Clock); #1;
            @(posedge Clock); #1;
            render_idle = 1'b1;
            @(posedge Clock); #1;
        end
    endtask

    initial 
    begin
        @(posedge Clock); #1;
        Resetn = 1'b1; // make sure reset is inactive

        // Spawn a block, for example O
        spawn = 1'b1;
        @(posedge Clock); #1;
        spawn = 1'b0;

        // wait for render
        do_render;

        // Move the block left
        cmd_in = 3'b001;
        cmd_valid = 1'b1;
        @(posedge Clock) #1;
        cmd_valid = 1'b0;
        @(posedge Clock) #1;

        do_render;

        // Move the block down, but suppose it's blocked
        blocked = 1'b1;
        cmd_in = 3'b011; cmd_valid = 1'b1;
        @(posedge Clock) #1;
        cmd_valid = 1'b0;
        @(posedge Clock) #1;

    end



endmodule