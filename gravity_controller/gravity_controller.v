//block falls automatically even when you aren’t pressing 
//anything
//FPGA will know when to move it as it uses a counter

module gravity_controller(

input CLOCK_50, //FPGA’s 50MHz clock
input Resetn, //resets the counter when 0
input game_active, //indicates whether the game is currently playing
output reg gravity_counter //signals that it’s time for block to                               //fall

);
//counting up to 49,999,999. We need 26 bits because
//2^26 - 1 = 67,108,863
reg [25:0] counter;

//1HZ = 50,000,000 clock cycles
//parameter is constant
parameter MAX_COUNT = 26’d49999999;

//Resetn = 0 -> reset
//Resetn = 1 -> normal 
always @ (posedge CLOCK_50)
begin

//if Resetn equals 0 we reset both registers to 0
//we want the counter to start at a known value rather than a random
//one
  if(!Resetn)
  begin
    counter <= 0;
    gravity_counter <= 0;
  end

//once counter reaches 49,999,999, the clock resets,
//gravity_counter becomes 1 for 1 clock cycles,
//and the falling-block controller receives the signal
  else if(counter == MAX_COUNT)
  begin
//counter resets to 0
       counter <= 0;
//tells falling controller it can move block down
       gravity_counter <=1; 
  end



//keep counting
//every positive clock edge increases counter by 1
  else
  begin

//if counter hasn’t reached its maximum then:
//increase it by 1
//keep gravity pulse at 0
       counter <= counter + 1;
       gravity_counter <= 0;
   end
end

endmodule

        
