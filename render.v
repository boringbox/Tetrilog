// Author: Meilly Chen
// Basic rendering, line clearing, output to VGA

module render(CLOCK_50, SW, KEY, LEDR, HEX2, HEX1, HEX0, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK) 

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



// Set codes for different blocks
// All Tetriminos are made of 4 squares, 7 types total
parameter I = 3'b000, J = 3'b001, L = 3'b010, O = 3'b011, S = 3'b100, T = 3'b101, Z = 3'b110;

// BASIC FUNCTIONALITY: start with T Tetrimino (3'b101)

// STATE 1: Draw background,
// STATE 2: Draw placed blocks, 
// STATE 3: Draw active block, 
// STATE 4: Idle (until next update)
// parameter S_BG = 2'b00, S_BLK = 2'b01, S_ACTIVE = 2'b10, S_IDLE = 2'b11;
// reg[1:0] y_Q; Y_D;
// wire go; // signal to go (stop waiting)

// always@(*) 
// begin: state_table
// case(y_Q)
// S_BG: 
// begin
//     drawBackground();
//     Y_D = S_BLK;
// end

// S_BLK:
// begin
//     drawBlocks();
//     Y_D = S_ACTIVE;
// end

// S_ACTIVE:
// begin
//     // Draw the current block
// end

// S_IDLE: Y_D = go ? S_BG : S_IDLE;

// default: Y_D = S_IDLE;

// endcase
// end // state_table

drawSquare U1(CLOCK_50, SW, KEY, LEDR, VGA_R, VGA_G, VGA_B,
                VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);


endmodule


module drawBlock(blockID)
// Composes a block out of 4 squares
always@(*)
begin: block_table
case(blockID)
I:

J:

L:

O:

S:

T:

Z:

default:

endcase
end // block_table


endmodule

module drawBackground()
// Draws the background
// BASIC FUNCTIONALITY: black screen


endmodule

module drawBlocks()
// Draws placed blocks


endmodule

module lineClear()
// Clears the top line of blocks


endmodule