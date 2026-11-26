
module game_over(
   input CLOCK_50,
   input Resetn,
   input start,
   input check_spawn,
   input spawn_blocked,

   output wire game_active,
   output wire game_over
);

// Two bits are enough to represent the three game states.
reg [1:0] state;

// Each parameter gives a readable name to a binary state.
parameter READY = 2'b00,
          PLAYING = 2'b01,
          GAME_OVER = 2'b10;

// This is the sequential part of the FSM.
// The state can only change on a rising clock edge.
always @(posedge CLOCK_50)
begin

   // Reset the FSM to READY when Resetn is 0.
   if(!Resetn)
   begin
     state <= READY;
   end

   else
   begin

        // Examine the current state and decide the next state.
        case(state)

             // The game is waiting for the player to start.
             READY:
             begin
                if(start)
                   state <= PLAYING;
                else
                   state <= READY;
             end

             // The game is running.
             // Check whether the next piece can spawn.
             PLAYING:
             begin
                if(check_spawn && spawn_blocked)
                   state <= GAME_OVER;
                else
                   state <= PLAYING;
             end

             // Once the game is over, remain in this state.
             GAME_OVER:
             begin
               state <= GAME_OVER;
             end

             // If an invalid state occurs, return to READY.
             default:
                   state <= READY;
          endcase
     end
end

// These outputs are determined by the current FSM state.
// They are combinational outputs, not additional registers.
assign game_active = (state == PLAYING);
assign game_over = (state == GAME_OVER);

endmodule

