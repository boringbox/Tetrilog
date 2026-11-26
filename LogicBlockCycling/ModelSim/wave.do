vlib work
vlog LogicBlockCycling.v testbench.v
vsim work.testbench

add wave -radix binary   /testbench/CLOCK_50
add wave -radix binary   /testbench/Resetn
add wave -radix binary   /testbench/NextBlock
add wave -radix unsigned /testbench/Piece

configure wave -timelineunits ns
run 500 ns