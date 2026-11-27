module Tetrilog(CLOCK_50, KEY, PS2_CLK, PS2_DAT, LEDR,
                VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK);

/*
States of Game FSM
INITIALISE 
PARSE_INPUT
UPDATE
RENDER 
WAIT
GAME_OVER

*/
input  CLOCK_50;
input  [3:0] KEY;
inout  PS2_CLK, PS2_DAT;
output [9:0] LEDR;
output [7:0] VGA_R, VGA_G, VGA_B;
output VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_CLK;

// Top Level States
parameter[5:0] INITIALISE = 6'b000001;
parameter[5:0] PARSE      = 6'b000010;
parameter[5:0] UPDATE     = 6'b000100;
parameter[5:0] RENDER     = 6'b001000;
parameter[5:0] WAIT       = 6'b010000;
parameter[5:0] GAMEOVER   = 6'b100000;

reg[5:0] Current;
reg[5:0] Next; 

wire Resetn = KEY[0];
wire Start, Game_Over, Update_Done, Render_Done, Wait_Done; 
assign Start = ~KEY[1] // When KEY1 Pressed

// Submodule Parameters
 	parameter [2:0] CMD_NONE  = 3'b000;
    parameter [2:0] CMD_LEFT  = 3'b001;
    parameter [2:0] CMD_RIGHT = 3'b010;
    parameter [2:0] CMD_DOWN  = 3'b011;
    parameter [2:0] CMD_PLACE = 3'b100;
    parameter [2:0] CMD_ROTATE= 3'b101;

	localparam [3:0] R_IDLE = 4'd2;   // render.v's S_IDLE

	
always@(*)
begin: state_table
	Next = Current;
	case(Current)
	

	INITIALISE: if(Start)
		begin
		Next = PARSE;
		end
	PARSE: 
		begin
		Next = UPDATE;
		end
	UPDATE:
		begin 
			if(Game_Over)
				Next = GAMEOVER;
			else if(Update_Done)
				Next = RENDER;
		end
	RENDER:
		begin
			if(Render_Done)
				Next = WAIT;
		end
	WAIT: 
		begin
			if(Wait_Done)
				Next = PARSE;
		end
	GAMEOVER: 
		begin
			if(Start)
				Next = INITIALISE;
		end
	default: Next = INITIALISE;
	endcase
end 

 // state register
  always @(posedge CLOCK_50) 
  begin: state_FFs
    if (!Resetn) 
		Current <= INITIALISE;
    else         
		Current <= Next;
  end

endmodule 