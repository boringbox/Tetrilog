# render y_Q:
#   0 INIT, 1 INIT_WAIT, 2 IDLE,
#   3 ERASE, 4 ERASE_WAIT, 5 DRAW_ACTIVE, 6 DRAW_ACTIVE_WAIT,
#   7 DRAW_PLACED, 8 DRAW_PLACED_WAIT, 9 CLEAR, 10 CLEAR_WAIT
# draw_square y_Q: 0 WAIT, 1 X, 2 Y, 3 DONE

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {go signals}
add wave -noupdate /testbench/CLOCK_50
add wave -noupdate /testbench/resetn
add wave -noupdate /testbench/block_moved
add wave -noupdate /testbench/block_locked
add wave -noupdate /testbench/redraw_board
add wave -noupdate /testbench/render_idle

add wave -noupdate -divider {render state}
add wave -noupdate -radix unsigned /testbench/DUT/y_Q
add wave -noupdate -radix unsigned /testbench/DUT/cellID
add wave -noupdate -radix unsigned /testbench/DUT/gx
add wave -noupdate -radix unsigned /testbench/DUT/gy

add wave -noupdate -divider {square being drawn}
add wave -noupdate -radix unsigned /testbench/DUT/DRAWER/y_Q
add wave -noupdate /testbench/DUT/draw_start
add wave -noupdate /testbench/DUT/draw_done

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 220
configure wave -valuecolwidth 60
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
WaveRestoreZoom {0 ns} {80000 ns}
