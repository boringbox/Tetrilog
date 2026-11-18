// This module is written to decode the players movement from the PS2 Controller 

    // Want to read the following keys the Arrow keys and Space Bar, "C", "R", Can also do wasd same as arrow keys

    // We can show if the thing is decoded by first inputting on the board 

    // Code:
    // 1: Arrow Up or W
    // 2: Arrow Down or S
    // 3: Arrow Left or A
    // 4: Arrow Right or D
    // 5: Spacebar to place
    // 6: R to rotate
    // 7: C to keep 
    // KEY[0] = reset; 

module PlayerDecoder( CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam [2:0] CMD_NONE = 3'b000;
localparam [2:0] CMD_UP = 3'b001;
localparam [2:0] CMD_LEFT = 3'b010;
localparam [2:0] CMD_RIGHT = 3'b011;
localparam [2:0] CMD_DOWN = 3'b100;
localparam [2:0] CMD_PLACE = 3'b101;
localparam [2:0] CMD_ROTATE = 3'b110;
localparam [2:0] CMD_HOLD = 3'b111;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
    input CLOCK_50;
    input [3:0] KEY; 
    inout PS2_CLK;
    inout PS2_DAT;
    output [9:0] LEDR;

/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
wire [7:0] ps2_key_data;
wire ps2_key_pressed;

// Internal Registers
 
reg ext; // 1 = E0 
reg brk; // 1 = F0
reg [2:0] cmd;  // code (1-7) of the current byte, 0 = do nothing 
reg	[7:1] held; // Links to the code above, 1-7 are for the valid keys

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
always @(posedge CLOCK_50)
begin
    if(KEY[0] == 1'b0)
    begin 
        ext <= 1'b0;
        brk <= 1'b0;
        held <= 7'b0;
    end
    else if (ps2_key_pressed == 1'b1)
    begin
        if (ps2_key_data == 8'hE0)
            ext <= 1'b1;
        else if (ps2_key_data == 8'hF0)
            brk <= 1'b1;
        else 
        begin 
            if( cmd != CMD_NONE)
                held[cmd] = ~brk;
        
            ext <= 1'b0; 
            brk <= 1'b0; 
        end
    end
end

/*****************************************************************************
 *                            Combinational Logic                            *
 *****************************************************************************/

always @(*)
begin
    case ({ext, ps2_key_data})
        9'h175, 9'h01D: cmd = CMD_UP;       // Up arrow    (E0 75), W (1D)
        9'h172, 9'h01B: cmd = CMD_DOWN;     // Down arrow  (E0 72), S (1B)
        9'h16B, 9'h01C: cmd = CMD_LEFT;     // Left arrow  (E0 6B), A (1C)
        9'h174, 9'h023: cmd = CMD_RIGHT;    // Right arrow (E0 74), D (23)
        9'h029, 9'h032: cmd = CMD_PLACE;    // Space (29), B (32)
        9'h02D:         cmd = CMD_ROTATE;   // R (2D)
        9'h021:         cmd = CMD_HOLD;     // C (21)
        default:        cmd = CMD_NONE;
    endcase
end
 
assign LEDR[6:0] = held;   // held[1] -> LEDR[0] ... held[7] -> LEDR[6]
assign LEDR[9:7] = 3'b000; // Always off

/*****************************************************************************
 *                              Internal Modules                             *
 *****************************************************************************/

PS2_Controller PS2 (
	// Inputs
	.CLOCK_50 (CLOCK_50),
	.reset (~KEY[0]),

	// Bidirectionals
	.PS2_CLK (PS2_CLK),
 	.PS2_DAT (PS2_DAT),

	// Outputs
	.received_data (ps2_key_data),
	.received_data_en (ps2_key_pressed)
);

endmodule
