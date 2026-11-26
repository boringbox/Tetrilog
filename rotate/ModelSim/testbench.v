`timescale 1ns/1ps

// Feed the rotated grid back in so the same piece turns three times.
module testbench();
    reg [47:0] blockGrid;
    wire [47:0] newBlockGrid;

    rotate DUT (
        .blockGrid(blockGrid),
        .newBlockGrid(newBlockGrid)
    );

    initial begin
        blockGrid = 48'h0000000DB018; // T
        #10; // 1
        blockGrid = newBlockGrid;
        #10; // 2
        blockGrid = newBlockGrid;
        #10; // 3
        $stop;
    end
endmodule
