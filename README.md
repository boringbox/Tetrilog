# Tetrilog
This is a project for the course ECE241; it involves the use of Verilog and the FPGA board DE1-SOC.

## Overview 
The project is a game of Tetris that runs on the FPGA board, using a keyboard to read player input, and using the VGA extension to connect the visual of the game to a monitor. For the basic functionality of the game, we will implement the player moving the block (Rotating block and block left/right), block falling to ground, what block will be given (initially we can cycle between all 7 blocks), placing block down, clear a line, basic rendering, when the game is over. As stretch goals, we can implement a random block generator, allow the player to hold the current piece to use later, display the next block, speed of the block increasing as the game progresses, audio.

## Block Diagram
~[Block Diagram of Design](docs/blockdiagram.png)
