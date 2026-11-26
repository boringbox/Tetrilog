vlib work
vlog Randomiser.v testbench.v
vsim work.testbench

add wave -radix binary   /testbench/CLOCK_50
add wave -radix binary   /testbench/Resetn
add wave -radix binary   /testbench/NextBlock
add wave -radix unsigned /testbench/Piece
add wave -radix hex      /testbench/U1/rando

configure wave -timelineunits ns
wave zoom full
run 650 ns