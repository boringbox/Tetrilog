//This module tells the game when a piece should move down
//At starting level, the block will drop every 1 second
//As level increaces, the interval decreaces
// LEVEL | DROP INTERVAL (seconds)
//---------------------------------
//   0   |         1    [50 million cycles]
//   1   |        0.9   [45 million cycles]
//   2   |        0.8   [40 million cycles]
//   3   |        0.7   [35 million cycles]
//   4   |        0.6   [30 million cycles]
//   5   |        0.5   [25 million cycles]
//   6   |        0.4   [20 million cycles]   
//   7   |        0.3   [15 million cycles]
//   8   |        0.2   [10 million cycles]
//   9+  |        0.1   [5 million  cycles]

//drop interval = 50,000,000 - (level x 5,000,000)
//e.g., at level 2: drop interval = 40,000,000
//at 50MHz -> 40,000,000/50,000,000 = 0.8 seconds


module gravity_controller(
input CLOCK_50,
input Resetn,
input game_active,
input [3:0] level, //can represent values from 0-15

output reg gravity_counter
);

reg [25:0] clock_cycles; //count how many clock cyles passed since last automatic drop
reg [25:0] drop_interval; //number of clock cycles we wait before dropping the piece

//calculate the drop interval from the current level
always @(*) begin

//if level is 9 or greater, keep the interval at 5 million cycles
if(level >= 4'd9)
   drop_interval = 26'd5000000;
else 

   drop_interval = 26'd50000000 - (level * 26'd5000000);
end

//calculate clock cycles and generate drop pulse
always @(posedge CLOCK_50) begin
if(!Resetn) begin

clock_cycles <= 26'd0;
gravity_counter <= 1'b0;
end

else if (!game_active)begin

clock_cycles <= 26'd0;
gravity_counter <= 1'b0;

end

else begin
//default is no drop pulse because we want a pulse rather than a
//permanant high signal
gravity_counter <= 1'b0;

if (clock_cycles >= drop_interval - 1'b1) begin

//when interval is reached, it resets and sends a pulse
   clock_cycles <= 26'd0; //resets
	gravity_counter <= 1'b1; //sends pulse
end

else begin
    //every clock edge
    clock_cycles <= clock_cycles + 1'b1;
	 
	 end
	 
	end
	
  end
  
 endmodule
 
