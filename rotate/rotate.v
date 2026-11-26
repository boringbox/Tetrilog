// Given the current rotation position of a block and the block's ID, shifts block
/*

BLOCK IDS (following block cycler)
-----------
3'd1: I (cyan)
3'd2: O (yellow)
3'd3: T (purple)
3'd4: J (blue)
3'd5: L (orange)
3'd6: S (green)
3'd7: Z (red)
*/


module rotate(blockGrid, newBlockGrid);

    // Expectation: block is represented by a 4x4 grid and each cell in the grid is:
    // 3'd0: empty
    // 3'd1-3'd7: filled (one of the colours)

    // 48 bits: 4x4 grid, and each grid stores 3 bits
    input [47:0] blockGrid;
    output reg [47:0] newBlockGrid;

    // Use a rotation matrix to transform the coords to a 90 degree CW rotation?
    // "transform" is just shifting the data in the cells around
    // x' = -y + 3, y' = x

    integer r, c;
    always @(*) begin
        for (r = 0; r < 4; r = r + 1)
            for (c = 0; c < 4; c = c + 1)
                newBlockGrid[((3-c)*4 + r)*3 +: 3] = blockGrid[(r*4 + c)*3 +: 3];
    end

endmodule
