
//This module recieves the number fo rows detected by the combo detector
//and it updates the score, total lines cleared, and level
//The scoring looks like the following:
// ROWS CLEARED |  POINTS
//---------------------------------
//     1        |   100
//     2        |   300
//     3        |   500
//     4        |   800
//
//level increase:
// TOTAL LINES    |  LEVEL
//    0-9         |    0
//   10-19        |    1
//   20-29        |    2
//   30-39        |    3

module scoring_controller (
    input Clock,
    input Resetn,

    input line_clear_event,
    input [4:0] lines_cleared,

    output reg [31:0] score, //total points accumulated through game
    output reg [9:0] total_lines, //10 bits
    output reg [3:0] level
);

    reg [31:0] points; //points earned from this particular line
    wire [10:0] total_lines_after_clear;

    // Calculate the new total number of lines
	 //total_lines can represent 1023 values(2^10) 
	 //lines_cleared can represend 31 values (2^5)
	 //maximum possible sum is 1054, therefore we need 11 bits (2047)
	 //concatenate total_lines and lines_cleared to be 11 bits
    assign total_lines_after_clear = {1'b0, total_lines} + {6'b0, lines_cleared};

    // Determine points from the number of lines cleared
    always @(*) begin

        points = 32'd0;

        case (lines_cleared)

            5'd1: points = 32'd100;
            5'd2: points = 32'd300; 
            5'd3: points = 32'd500;
            5'd4: points = 32'd800;

            default: points = 32'd0;

        endcase

    end

    // Update stored score, line count, and level
    always @(posedge Clock) begin

        if (!Resetn) begin

            score <= 32'd0;
            total_lines <= 10'd0;
            level <= 4'd0;

        end

        else if (line_clear_event && lines_cleared != 5'd0) begin

            score <= score + points;

            total_lines <= total_lines_after_clear[9:0];


 if ((total_lines_after_clear) >= 10)
    level <= (total_lines_after_clear) / 10;
	 
  end
 
 end
 
endmodule
 