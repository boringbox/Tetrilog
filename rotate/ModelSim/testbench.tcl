# stop any simulation that is currently running
catch {quit -sim}

# create the default "work" library
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# compile the Verilog source code in the parent folder
vlog ../*.v

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator
vsim work.testbench -voptargs=+acc

# show waveforms specified in wave.do
do wave.do

# testbench calls $stop when the checks finish
run -all
