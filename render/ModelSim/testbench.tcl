# stop any simulation that is currently running
quit -sim

# recreate the work library so a second run starts clean
if {[file exists work]} {
    vdel -lib work -all
}
vlib work

# altsyncram loads BACKGROUND_IMAGE from the simulation directory
if {[file exists rainbow_640_9.mif]} {
    file delete rainbow_640_9.mif
}
file copy ../rainbow_640_9.mif .

# compile the design and the testbench
vlog ../vga_adapter.v
vlog ../vga_address_translator.v
vlog ../vga_controller.v
vlog ../vga_pll.v
vlog ../render.v
vlog ../top.v
vlog testbench.v

# altera_mf_ver supplies altpll and altsyncram; +acc keeps internal signals visible
vsim -voptargs=+acc -L altera_mf_ver work.testbench

# show waveforms specified in wave.do
do wave.do

# stimulus in testbench.v ends around 140 ns
run 200 ns
