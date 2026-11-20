# stop any simulation that is currently running
quit -sim

# create the default "work" library
vlib work

# altsyncram loads BACKGROUND_IMAGE from the simulation directory
if {[file exists ../rainbow_640_9.mif]} {
    file copy ../rainbow_640_9.mif .
}

# compile the Verilog source code in the parent folder
vlog ../*.v

# compile the Verilog code of the testbench
vlog *.v

# start the Simulator, including some libraries
vsim work.testbench -voptargs=+acc -L altera_mf_ver -Lf verilog

# show waveforms specified in wave.do
do wave.do

# stimulus in testbench.v ends around 140 ns
run 10000000 ns
