SHELL=/bin/bash
IVERILOG=iverilog -g2012 -Wall -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array -y./hdl -y./tests -Y.sv -I./hdl
VVP=vvp
VVP_POST=-fst
VIVADO=vivado -mode batch -source

# Add any new source files needed for the final bitstream here
MAIN_SRCS=hdl/main.sv hdl/block_ram.sv

test_main: tests/test_main.sv ${MAIN_SRCS} memories/sine_samples.memh memories/zeros.memh
	${IVERILOG} tests/test_main.sv ${MAIN_SRCS} -o test_main.bin && ${VVP} test_main.bin ${VVP_POST}

waves_main: test_main
	gtkwave main.fst -a tests/main.gtkw

program_fpga_vivado: rv32i_system.bit build.tcl program.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Vivado)      ####"
	@echo "########################################"
	${VIVADO} program.tcl

program_fpga_digilent: rv32i_system.bit build.tcl
	@echo "########################################"
	@echo "#### Programming FPGA (Digilent)    ####"
	@echo "########################################"
	djtgcfg enum
	djtgcfg prog -d CmodA7 -i 0 -f rv32i_system.bit

lint_all: hdl/*.sv
	verilator --lint-only -DSIMULATION -I./hdl -I./tests $^

# Call this to clean up all your generated files
clean:
	rm -f *.bin *.vcd *.fst vivado*.log *.jou vivado*.str *.log *.checkpoint *.bit *.html *.xml *.out
	rm -rf .Xil
	rm -rf __pycache__
