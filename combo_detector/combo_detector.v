//A row is considered complete when all 10 cells of the row are occupied
//The detector tells the rest of the game which rows are full,
//how many rows are full, and whether a line clearing has been detected

module combo_detector (

input check_enable,
input [199:0] board_cells,

output reg [19:0] full_rows,
output reg [4:0] lines_cleared,
output reg combo_detected

);

integer row, col;

//combinational logic
//detector continuously evaluates board and updated its outputs whenever 
//an input changes
always @(*) begin

//start with no full rows
full_rows = 20'b0;
lines_cleared = 5'd0;//5 bit number to represent 0-20 (for 20 rows on the board)
combo_detected = 1'b0;

if(check_enable) begin

//examines all 20 rows
for (row = 0; row < 20; row = row+1) 
begin

//assume row is full initially
//then search for empty cell
full_rows[row] = 1'b1;

//examine every column (10 cells) in this row
for(col = 0; col < 10; col = col + 1) 
begin

//if even one emty cell is found:
if(board_cells[row*10 + col] == 1'b0)
//row is no longer full and we change bit to 0
full_rows[row] = 1'b0;
end

//count row if it's full
if(full_rows[row] == 1'b1)
//counter increment
lines_cleared = lines_cleared + 5'd1;

end

//a combo is detected if at least one row is full
//in other words, at least one full row was found
if(lines_cleared != 5'd0)
combo_detected = 1'b1;
end

end

endmodule
