// This module is written to decode the players movement from the PS2 Controller 

    // Want to read the following keys the Arrow keys and Space Bar, "C", "R", Can also do wasd same as arrow keys

    // We can show if the thing is decoded by first inputting on the board 
    // Command codes output on cmd_out:
        // CMD_LEFT   (001): Left arrow / A
        // CMD_RIGHT  (010): Right arrow / D
        // CMD_DOWN   (011): Down arrow / S
        // CMD_PLACE  (100): Space / B
        // CMD_ROTATE (101): R
        // CMD_HOLD   (110): C
        // cmd_valid pulses high for 1 clock on each key press (including keyboard auto-repeat)

module LogicPlayerDecode( CLOCK_50, KEY, PS2_CLK, PS2_DAT, cmd_out, cmd_valid);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/
localparam [2:0] CMD_NONE   = 3'b000;
localparam [2:0] CMD_LEFT   = 3'b001;
localparam [2:0] CMD_RIGHT  = 3'b010;
localparam [2:0] CMD_DOWN   = 3'b011;
localparam [2:0] CMD_PLACE  = 3'b100;
localparam [2:0] CMD_ROTATE = 3'b101;
localparam [2:0] CMD_HOLD   = 3'b110;

/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/
    input CLOCK_50;
    input [3:0] KEY; 
    inout PS2_CLK;
    inout PS2_DAT;
	output reg [2:0] cmd_out;
    output reg cmd_valid;   // high for exactly 1 clock per key press
	 
/*****************************************************************************
 *                 Internal Wires and Registers Declarations                 *
 *****************************************************************************/
wire [7:0] ps2_key_data;
wire ps2_key_pressed;

// Internal Registers
reg ext; // 1 = E0 
reg brk; // 1 = F0  
reg [2:0] cmd;  // code (1-6) of the current byte, 0 = do nothing 
reg [6:1] held; // one bit per command code 1-6, high while that key is held

/*****************************************************************************
 *                         Finite State Machine(s)                           *
 *****************************************************************************/
always @(posedge CLOCK_50)
begin
    cmd_valid <= 1'b0;                 // default: no event this cycle
    if (KEY[0] == 1'b0) begin
        ext <= 1'b0;
        brk <= 1'b0;
        held <= 6'b0;
        cmd_out <= CMD_NONE;
    end
    else if (ps2_key_pressed) begin
        if (ps2_key_data == 8'hE0)
            ext <= 1'b1;
        else if (ps2_key_data == 8'hF0)
            brk <= 1'b1;
        else begin
            if (cmd != CMD_NONE) begin
                held[cmd] <= ~brk;     // note: <= not =
                if (!brk) begin        // make code = key pressed
                    cmd_out   <= cmd;
                    cmd_valid <= 1'b1;
                end
            end
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
        9'h172, 9'h01B: cmd = CMD_DOWN;     // Down arrow  (E0 72), S (1B)
        9'h16B, 9'h01C: cmd = CMD_LEFT;     // Left arrow  (E0 6B), A (1C)
        9'h174, 9'h023: cmd = CMD_RIGHT;    // Right arrow (E0 74), D (23)
        9'h029, 9'h032: cmd = CMD_PLACE;    // Space (29), B (32)
        9'h02D:         cmd = CMD_ROTATE;   // R (2D)
        9'h021:         cmd = CMD_HOLD;     // C (21)
        default:        cmd = CMD_NONE;
    endcase
end

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
