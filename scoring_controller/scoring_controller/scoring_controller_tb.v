//tests 4 clearing events:
// Clear 1 row then 4 rows
//Clear 4 rows then 1 row
//This demonstrates both scoring and reaching level 1


`timescale 1ns/1ps

module scoring_controller_tb;

reg Clock;
reg Resetn;// Resetn = 0 -> reset score, lines, and level
//Resetn = 1 -> normal operation
reg line_clear_event;
reg [4:0] lines_cleared;

wire [31:0] score;
wire [9:0] total_lines;
wire [3:0] level;

// Generate clock
//start at 0
//after 5 ns, change to 1
//after another 5 ns, change to 0
//repeat
initial Clock = 1'b0;
always #5 Clock = ~Clock;

// Connect scoring controller
scoring_controller DUT (
.Clock(Clock),
.Resetn(Resetn),
.line_clear_event(line_clear_event),
.lines_cleared(lines_cleared),
.score(score),
.total_lines(total_lines),
.level(level)
);

initial begin

// Initial values
Resetn = 1'b0;
line_clear_event = 1'b0;
lines_cleared = 5'd0;
//wait for 2 clock edges, then release
repeat (2) @(posedge Clock);
#1;
Resetn = 1'b1;

// TEST 1: Clear 1 row
@(posedge Clock);
#1;
lines_cleared = 5'd1;
line_clear_event = 1'b1; //row-clearing event happened, UPDATE SCORE

@(posedge Clock);
#1;
line_clear_event = 1'b0;
lines_cleared = 5'd0;

// TEST 2: Clear 4 rows
@(posedge Clock);
#1;
lines_cleared = 5'd4;
line_clear_event = 1'b1;

@(posedge Clock);
#1;
line_clear_event = 1'b0;
lines_cleared = 5'd0;

// TEST 3: Clear another 4 rows
@(posedge Clock);
#1;
lines_cleared = 5'd4;
line_clear_event = 1'b1;

@(posedge Clock);
#1;
line_clear_event = 1'b0;
lines_cleared = 5'd0;

// TEST 4: Clear 1 more row
@(posedge Clock);
#1;
lines_cleared = 5'd1;
line_clear_event = 1'b1;

@(posedge Clock);
#1;
line_clear_event = 1'b0;
lines_cleared = 5'd0;

repeat (2) @(posedge Clock);
#1;

$display("Final score = %d", score);
$display("Total lines = %d", total_lines);
$display("Level = %d", level);

$finish;

end

endmodule
