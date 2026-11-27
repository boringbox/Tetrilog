
//this module makes your block move
//checks whether piece can move down
module falling_controller(
   input CLOCK_50,
   input Resetn,
   input game_active,
   input gravity_counter,
   input down_blocked,
   input new_piece,

   input [4:0] spawn_y,

   output reg [4:0] block_y,
   output reg lock_piece
);

// Sequential logic: block_y and lock_piece are registers.
// Their values are updated on the rising edge of CLOCK_50.
always @(posedge CLOCK_50)
begin

   if(!Resetn)
   begin
     block_y <= 0;
     lock_piece <= 0;
   end

   else
   begin

     //default is no locking signal
     lock_piece <= 0;

     // A newly created piece is placed at its spawn row.
     // This takes priority over the gravity movement.
     if(new_piece)
     begin
       block_y <= spawn_y;
     end 

//only considers falling when game is active
//and when gravity timer generated a pulse
     else if (game_active && gravity_counter)
     begin
       
//if there is no collision, move down 
       if(!down_blocked)      
       begin
         block_y <= block_y + 1;
       end
//otherwise, piece has landed
       else
       begin
         lock_piece <= 1;
       end
    end
  end
end

endmodule
