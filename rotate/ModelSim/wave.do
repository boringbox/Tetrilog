# Cell labels are row-major, row 0 at the top.
# newBlockGrid is the 1st, 2nd, and 3rd turn at 0 ns, 10 ns, and 20 ns.

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {input grid}
add wave -noupdate -radix hexadecimal /testbench/DUT/blockGrid
add wave -noupdate -radix unsigned -label r0c0 /testbench/DUT/blockGrid[2:0]
add wave -noupdate -radix unsigned -label r0c1 /testbench/DUT/blockGrid[5:3]
add wave -noupdate -radix unsigned -label r0c2 /testbench/DUT/blockGrid[8:6]
add wave -noupdate -radix unsigned -label r0c3 /testbench/DUT/blockGrid[11:9]
add wave -noupdate -radix unsigned -label r1c0 /testbench/DUT/blockGrid[14:12]
add wave -noupdate -radix unsigned -label r1c1 /testbench/DUT/blockGrid[17:15]
add wave -noupdate -radix unsigned -label r1c2 /testbench/DUT/blockGrid[20:18]
add wave -noupdate -radix unsigned -label r1c3 /testbench/DUT/blockGrid[23:21]
add wave -noupdate -radix unsigned -label r2c0 /testbench/DUT/blockGrid[26:24]
add wave -noupdate -radix unsigned -label r2c1 /testbench/DUT/blockGrid[29:27]
add wave -noupdate -radix unsigned -label r2c2 /testbench/DUT/blockGrid[32:30]
add wave -noupdate -radix unsigned -label r2c3 /testbench/DUT/blockGrid[35:33]
add wave -noupdate -radix unsigned -label r3c0 /testbench/DUT/blockGrid[38:36]
add wave -noupdate -radix unsigned -label r3c1 /testbench/DUT/blockGrid[41:39]
add wave -noupdate -radix unsigned -label r3c2 /testbench/DUT/blockGrid[44:42]
add wave -noupdate -radix unsigned -label r3c3 /testbench/DUT/blockGrid[47:45]

add wave -noupdate -divider {rotated grid}
add wave -noupdate -radix hexadecimal /testbench/DUT/newBlockGrid
add wave -noupdate -radix unsigned -label r0c0 /testbench/DUT/newBlockGrid[2:0]
add wave -noupdate -radix unsigned -label r0c1 /testbench/DUT/newBlockGrid[5:3]
add wave -noupdate -radix unsigned -label r0c2 /testbench/DUT/newBlockGrid[8:6]
add wave -noupdate -radix unsigned -label r0c3 /testbench/DUT/newBlockGrid[11:9]
add wave -noupdate -radix unsigned -label r1c0 /testbench/DUT/newBlockGrid[14:12]
add wave -noupdate -radix unsigned -label r1c1 /testbench/DUT/newBlockGrid[17:15]
add wave -noupdate -radix unsigned -label r1c2 /testbench/DUT/newBlockGrid[20:18]
add wave -noupdate -radix unsigned -label r1c3 /testbench/DUT/newBlockGrid[23:21]
add wave -noupdate -radix unsigned -label r2c0 /testbench/DUT/newBlockGrid[26:24]
add wave -noupdate -radix unsigned -label r2c1 /testbench/DUT/newBlockGrid[29:27]
add wave -noupdate -radix unsigned -label r2c2 /testbench/DUT/newBlockGrid[32:30]
add wave -noupdate -radix unsigned -label r2c3 /testbench/DUT/newBlockGrid[35:33]
add wave -noupdate -radix unsigned -label r3c0 /testbench/DUT/newBlockGrid[38:36]
add wave -noupdate -radix unsigned -label r3c1 /testbench/DUT/newBlockGrid[41:39]
add wave -noupdate -radix unsigned -label r3c2 /testbench/DUT/newBlockGrid[44:42]
add wave -noupdate -radix unsigned -label r3c3 /testbench/DUT/newBlockGrid[47:45]

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {40 ns}
