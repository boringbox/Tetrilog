// Draws a single square on the screen 
// Adapted from COLORS demo

/*
 *  This code serves as an example that illustrates usage of the VGA output in the DE1-SoC 
 *  board. The code uses a VGA adapter to send pixel colors to the VGA display. To use the demo 
 *  first press KEY[0] to reset the circuit. It will display the contents of a video memory
 *  in the VGA adapter as a background image. Then, the user can choose to draw a colored box
 *  that is centered in the VGA display, by pressing KEY[3]. The box color is displayed on 
 *  LEDR[8:0], and the size of the box is displayed as a hexadecimal number on HEX1-0. You can
 *  set the color of the box by specifying any 9-bit color on switches SW[8:0] and then pressing
 *  KEY[1]. You can set the size of the box by specifying a new size on the SW switches and then
 *  pressing KEY[2]. Press KEY[3] to draw the box.
 *
*/

module drawBlock(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);
    /*
    - Block is drawn in a 16x16 grid (to accomodate all possible square positions)
    - Each block is made of 4 squares

    */

    input CLOCK_50;    
    input [9:0] SW;
    input [3:0] KEY;
    output [9:0] LEDR;
    output [6:0] HEX2, HEX1, HEX0;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_HS;
    output VGA_VS;
    output VGA_BLANK_N;
    output VGA_SYNC_N;
    output VGA_CLK;    
    

    // // for now, use SW to set the block id
    // wire [3:0] blockID;
    // assign blockID = SW[3:0];

    // Set codes for different blocks
    // All Tetriminos are made of 4 squares, 7 types total
    parameter I = 3'b000, J = 3'b001, L = 3'b010, O = 3'b011, S = 3'b100, T = 3'b101, Z = 3'b110;
 
    // BASIC FUNCTIONALITY: start with T Tetrimino (3'b101)
    drawSquare S0(0, 3);
    drawSquare S1(1, 3);
    drawSquare S2(2, 3);
    drawSquare S3(1, 2);


    // always@(*)
    // begin: block_table
    // case(blockID)
    //     I:
    //     begin
    //         drawSquare S0(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
    //             VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, 0, 0);
    //         drawSquare S1(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
    //             VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, 0, 1);
    //         drawSquare S2(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
    //             VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, 0, 2);
    //         drawSquare S3(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
    //             VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK, 0, 3);
    //     end
    //     J:

    //     L:

    //     O:

    //     S:

    //     T:

    //     Z:

    //     default:

    // endcase
    // end // block_table


    vga_adapter VGA (
        .resetn(KEY[0]),
        .clock(CLOCK_50),
        .color(color),
        .x(X - (size >> 1) + XC),
        .y(Y - (size >> 1) + YC),
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

module drawSquare(GRID_X, GRID_Y, COLOUR);
  
    // Draw a single coloured square based on given coordinates and colour

    // specify the number of bits needed for an X (column) pixel coordinate on the VGA display
    parameter nX = 10;
    // specify the number of bits needed for a Y (row) pixel coordinate on the VGA display
    parameter nY = 9;

    // state codes for FSM that choses which object to draw at a given time
    parameter A = 2'b00, B = 2'b01, C = 2'b10, D = 2'b11;

    input [3:0] GRID_X, GRID_Y;
    
    wire [8:0] new_color, color;
    wire [nX-1:0] X;    // used to record the center of the box
    wire [nY-1:0] Y;    // used to record the center of the box
    wire [nY-1:0] new_size, size;
    wire [nX-1:0] X0, XC;           // box offsets and counters
    wire [nY-1:0] Y0, YC;
    wire go;                        // used by FSM
    reg write, Lxc, Lyc, Exc, Eyc;  // box control signals
    reg [1:0] y_Q, Y_D;             // FSM
    
    // use offsets to center the box on the VGA display
    // in practice: offsets should be passed in to change depending on block location
    parameter X_OFFSET = 320;
    parameter Y_OFFSET = 240;
    assign X0 = X_OFFSET + GRID_X*8;;
    assign Y0 = Y_OFFSET + GRID_Y*8;

    // set default color to white (111)
    // in practice: color should be passed in
    assign new_color = color == {9{1'b0}} ? {9{1'b1}} : SW[8:0];

    // set box size to 8 x 8 ? subject to change
    assign new_size = size == {nY{1'b0}} ? {{nY-4{1'b0}},4'b1000} : SW[nY-1:0];

    // these counter are used to generate pixel coordinates for the box
    Up_count U1 ({nX{1'd0}}, CLOCK_50, KEY[0], Lxc, Exc, XC);
        defparam U1.n = nX;
    Up_count U2 ({nY{1'd0}}, CLOCK_50, KEY[0], Lyc, Eyc, YC);
        defparam U2.n = nY;

    assign LEDR[9:0] = 10'b0;

    assign go = ~KEY[3];

    // FSM state table
    always @ (*)
        case (y_Q)
            A:  if (!go) Y_D = A;
                else Y_D = B;
            B:  if (XC != size-1) Y_D = B;  // box x coordinate (column)
                else Y_D = C;
            C:  if (YC != size-1) Y_D = B;  // box y coordinate (row)
                else Y_D = D;
            D:  Y_D = A;
        endcase
    // FSM outputs
    always @ (*)
    begin
        // default assignments
        write = 1'b0; Lxc = 1'b0; Lyc = 1'b0; Exc = 1'b0; Eyc = 1'b0;
        case (y_Q)
            A:  begin Lxc = 1'b1; Lyc = 1'b1; end   // load (XC,YC) counter
            B:  begin Exc = 1'b1; write = 1'b1; end // enable XC, write pixel
            C:  begin Lxc = 1'b1; Eyc = 1'b1; end   // enable YC, load XC
            D:  Lyc = 1'b1;                         // load YC
        endcase
    end

    always @(posedge CLOCK_50)
        if (!KEY[0])
            y_Q <= 2'b0;
        else
            y_Q <= Y_D;


endmodule

module regn(R, Resetn, E, Clock, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Resetn, E, Clock;
    output reg [n-1:0] Q;

    always @(posedge Clock)
        if (!Resetn)
            Q <= 0;
        else if (E)
            Q <= R;
endmodule

// n-bit up-counter with reset, load, and enable
module Up_count (R, Clock, Resetn, L, E, Q);
    parameter n = 8;
    input [n-1:0] R;
    input Clock, Resetn, E, L;
    output reg [n-1:0] Q;

    always @ (posedge Clock)
        if (Resetn == 0)
            Q <= {n{1'b0}};
        else if (L == 1)
            Q <= R;
        else if (E)
            Q <= Q + 1'b1;
endmodule

