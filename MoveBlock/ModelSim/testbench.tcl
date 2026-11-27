# stop any simulation that is currently running
quit -sim

# create the default "work" library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# compile MoveBlock.v, then the testbench
vlog ../*.v
vlog *.v

# start the simulator
vsim work.testbench -voptargs=+acc

# show waveforms specified in wave.do
do wave.do

# the clock runs forever, so stop after the stimulus is done
run 800 ns