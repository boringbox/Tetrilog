
//determines whether piece is allowed to move
//collision detection uses the formula: index = (row x 10) + column
//this calculates which bit corresponds to a specific row & column

module collision_detector(

//use vector of 200 bits
// 10 columns x 20 rows = 200 cells
//each bit represents 1 square on Tetris board

   input [199:0] board_cells,
   
//active piece coordinates
//every Tetris piece consists of 4 individual squares
//each square will have it’s own coordinates
//[3:0] represents 0-15 which is enough for 10 columns
//[4:0] represents 0-31 which is enough for 20 rows

   input [3:0] x0, x1,x2,x3,
   input [4:0] y0, y1, y2, y3,

//new piece waiting to spawn coordinates

   input [3:0] sx0, sx1,sx2,sx3,
   input [4:0] sy0, sy1, sy2, sy3,

//down_blocked = 1: current piece cannot move down
//down_blocked = 0: current piece can move down
//spawn_blocked = 1: next piece cannot spawn
//spawn_blocked = 0: next piece can spawn

   output reg down_blocked,
   output reg spawn_blocked
);

//collision detection depends on the current coordinates and
//board content. Therefore, it is combinational logic
//whenever input changes, logic recalculates output hence this
//module doesn't need a clock

always @(*)
begin
   
//start by assuming neither collision exists because we need to
//check all four squares

   down_blocked = 0;
   spawn_blocked = 0;

//checking first cell
//x0 >= 10 means the square is outside the right edge of board
//y0 >= 19 square is on bottom row, if moved down it’ll be outside
//the board
//if either condition is true, block cannot move down
//else condition checks if soiree is immediately below the current 
//square occupied

if (x0 >= 10 || y0 >= 19)
    down_blocked = 1;
else if (board_cells[(y0+1)*10+x0])
     down_blocked = 1; //there is already a settled square there

//checking current cell position because a new piece hasn’t
//fallen yet. Want to know whether starting position is occupied
//Repeat 4 times for 4 squares in every piece

if(x0 >= 10 || y0 >= 20)
   spawn_blocked = 1;
else if(board_cells[y0*10 + x0])
   spawn_blocked = 1;

//checking second cell
if(x1 >= 10 || y1 >= 19)
   down_blocked = 1;
else if (board_cells[(y1+1)*10 + x1])
   down_blocked = 1;

if(x1 >= 10 || y1 >= 20)
   spawn_blocked = 1;
else if (board_cells[y1 * 10 + x1])
   spawn_blocked = 1;

//checking third cell
if(x2 >= 10 || y2 >= 19)
  down_blocked = 1;
else if (board_cells[(y2+1)*10 + x2])
  down_blocked = 1;

if(x2 >= 10 || y2 >= 20)
  spawn_blocked = 1;
else if (board_cells[y2*10 + x2])
  spawn_blocked = 1;

//checking fourth cell
if(x3 >= 10 || y3 >= 19)
  down_blocked = 1;
else if (board_cells[(y3+1)*10 + x3])
  down_blocked = 1;

if(x3 >= 10 || y3 >= 20)
  spawn_blocked = 1;
else if (board_cells[y3*10 + x3])
  spawn_blocked = 1;

 end

endmodule


