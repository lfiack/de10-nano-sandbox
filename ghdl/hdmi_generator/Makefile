FILE=hdmi_generator

all:
	ghdl -a $(FILE).vhd
	ghdl -a $(FILE)_tb.vhd
	ghdl -e $(FILE)_tb
	ghdl -r $(FILE)_tb --wave=$(FILE)_tb.ghw

gtkwave: all
	gtkwave $(FILE)_tb.ghw &