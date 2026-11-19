
module game_over(
   input CLOCK_50,
   input Resetn,
   input start,
   input check_spawn,
   input spawn_blocked

   output game_active,
   output game_over
);


reg [1:0] state;

parameter READY = 2’ b00,
          PLAYING = 2’b01,
          GAME_OVER = 2’b10;

always @(posedge CLOCK_50)
begin

   if(!Resetn)
   begin
     state <= READY;
   end

   else
   begin

        case(state)
             
             READY:
             begin
                if(start)
                   state <= PLAYING;
                else
                   state <= READY;
             end

             PLAYING:
             begin
                if(check_spawn && spawn_blocked)
                   state <= GAME_OVER;
                else
                   state <= PLAYING;
             end


             GAME_OVER:
             begin
               state <= GAME_OVER;
             end
                
             default:
                   state <= READY;
          endcase
     end
end

assign game_active = (state == PLAYING);
assign game_over = (state == GAME_OVER);

endmodule
