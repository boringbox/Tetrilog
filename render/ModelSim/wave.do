# render states: 0 INIT, 1 INIT_WAIT, 2 IDLE, 3 ERASE, 4 ERASE_WAIT,
#   5 DRAW_ACTIVE, 6 DRAW_ACTIVE_WAIT, 7 DRAW_PLACED, 8 DRAW_PLACED_WAIT,
#   9 CLEAR, 10 CLEAR_WAIT
# draw_square states: 0 WAIT, 1 RUN, 2 FLUSH, 3 DONE

onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {testbench}
add wave -noupdate /testbench/CLOCK_50
add wave -noupdate -radix binary /testbench/SW
add wave -noupdate -radix binary /testbench/KEY
add wave -noupdate -radix binary /testbench/LEDR

add wave -noupdate -divider {render}
add wave -noupdate -label resetn /testbench/DUT/U1/resetn
add wave -noupdate -label block_moved /testbench/DUT/U1/block_moved
add wave -noupdate -label block_locked /testbench/DUT/U1/block_locked
add wave -noupdate -label redraw_board /testbench/DUT/U1/redraw_board
add wave -noupdate -label render_idle /testbench/DUT/U1/render_idle
add wave -noupdate -radix unsigned -label render_state /testbench/DUT/U1/y_Q
add wave -noupdate -radix unsigned -label render_next /testbench/DUT/U1/Y_D
add wave -noupdate -radix unsigned /testbench/DUT/U1/cellID
add wave -noupdate -radix unsigned /testbench/DUT/U1/gx
add wave -noupdate -radix unsigned /testbench/DUT/U1/gy
add wave -noupdate -radix unsigned -label sel_x /testbench/DUT/U1/sel_x
add wave -noupdate -radix unsigned -label sel_y /testbench/DUT/U1/sel_y
add wave -noupdate /testbench/DUT/U1/draw_start
add wave -noupdate /testbench/DUT/U1/draw_done
add wave -noupdate -radix hexadecimal /testbench/DUT/U1/solid_colour

add wave -noupdate -divider {draw_square}
add wave -noupdate -radix unsigned -label draw_state /testbench/DUT/U1/DRAWER/y_Q
add wave -noupdate -radix unsigned /testbench/DUT/U1/DRAWER/Xc
add wave -noupdate -radix unsigned /testbench/DUT/U1/DRAWER/Yc
add wave -noupdate /testbench/DUT/U1/DRAWER/write
add wave -noupdate -radix unsigned /testbench/DUT/U1/DRAWER/pix_x
add wave -noupdate -radix unsigned /testbench/DUT/U1/DRAWER/pix_y
add wave -noupdate -radix hexadecimal /testbench/DUT/U1/DRAWER/vga_colour

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 180
configure wave -valuecolwidth 80
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
WaveRestoreZoom {0 ns} {10000000 ns}
