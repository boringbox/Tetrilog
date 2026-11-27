
//testbench tests 3 scenarios:
// 1. Empty board -> zero full rows
// 2. One full row -> detects one
// 3. Two full rows -> detects two

`timescale 1ns/1ps

module combo_detector_tb;

    // Inputs to the module
    reg check_enable;
    reg [199:0] board_cells;

    // Outputs from the combo detector
	 //module calculates these outputs, testbench doesn't do that
    wire [19:0] full_rows;
    wire [4:0] lines_cleared;
    wire combo_detected;

    integer i;

    // Instantiate the module we want to test
    combo_detector DUT (
        .check_enable(check_enable),
        .board_cells(board_cells),
        .full_rows(full_rows),
        .lines_cleared(lines_cleared),
        .combo_detected(combo_detected)
    );

    initial begin //execute testbench instructions from the begining of simulation

        // TEST 1: Reset inputs / empty board
        check_enable = 1'b1;
        board_cells = 200'b0; //200 cells empty

        #10; //wait 10 simulation time units

        $display("TEST 1: Empty board");
        $display("Lines cleared = %d", lines_cleared);
        $display("Combo detected = %b", combo_detected);


        // TEST 2: Fill row 5
        for (i = 0; i < 10; i = i + 1)
		  //fills bits 50-59
		  //index = (row x 10) + column
            board_cells[50 + i] = 1'b1;

        #10;

        $display("TEST 2: One full row");
        $display("Lines cleared = %d", lines_cleared);
        $display("Full rows = %b", full_rows);
        $display("Combo detected = %b", combo_detected);


        // TEST 3: Fill another row (row 6)
        for (i = 0; i < 10; i = i + 1)
		  //bits 60-69
            board_cells[60 + i] = 1'b1;

        #10;

        $display("TEST 3: Two full rows");
        $display("Lines cleared = %d", lines_cleared);
        $display("Full rows = %b", full_rows);
        $display("Combo detected = %b", combo_detected);

        $finish;

    end

endmodule