onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {inputs}
add wave -noupdate /testbench/Clock
add wave -noupdate /testbench/Resetn
add wave -noupdate -radix binary /testbench/cmd_in
add wave -noupdate /testbench/cmd_valid
add wave -noupdate -radix unsigned /testbench/piece
add wave -noupdate /testbench/spawn
add wave -noupdate /testbench/render_idle
add wave -noupdate /testbench/blocked

add wave -noupdate -divider {outputs}
add wave -noupdate /testbench/block_moved
add wave -noupdate /testbench/busy

add wave -noupdate -divider {where the piece is}
add wave -noupdate -radix unsigned /testbench/curr_x0
add wave -noupdate -radix unsigned /testbench/curr_y0
add wave -noupdate -radix unsigned /testbench/curr_x1
add wave -noupdate -radix unsigned /testbench/curr_y1
add wave -noupdate -radix unsigned /testbench/curr_x2
add wave -noupdate -radix unsigned /testbench/curr_y2
add wave -noupdate -radix unsigned /testbench/curr_x3
add wave -noupdate -radix unsigned /testbench/curr_y3

add wave -noupdate -divider {where it was}
add wave -noupdate -radix unsigned /testbench/old_x0
add wave -noupdate -radix unsigned /testbench/old_y0
add wave -noupdate -radix unsigned /testbench/old_x1
add wave -noupdate -radix unsigned /testbench/old_y1
add wave -noupdate -radix unsigned /testbench/old_x2
add wave -noupdate -radix unsigned /testbench/old_y2
add wave -noupdate -radix unsigned /testbench/old_x3
add wave -noupdate -radix unsigned /testbench/old_y3

add wave -noupdate -divider {inside MoveBlock}
# state is one-hot: IDLE = 001, RECEIVE = 010, PLOT = 100
add wave -noupdate -radix binary /testbench/DUT/y_Q
add wave -noupdate -radix unsigned /testbench/DUT/px
add wave -noupdate -radix unsigned /testbench/DUT/py
add wave -noupdate -radix unsigned /testbench/DUT/ox
add wave -noupdate -radix unsigned /testbench/DUT/oy
add wave -noupdate -radix binary /testbench/DUT/cmd
add wave -noupdate -radix unsigned /testbench/DUT/shape
add wave -noupdate /testbench/DUT/sent

TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ns} {800 ns}