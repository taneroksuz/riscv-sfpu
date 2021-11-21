default: none

GHDL ?= /opt/ghdl/bin/ghdl
VERILATOR ?= /opt/verilator/bin/verilator
SYSTEMC ?= /opt/systemc
TESTFLOAT ?= /opt/testfloat/testfloat_gen
PYTHON ?= /usr/bin/python3
SV2V ?= /opt/sv2v/bin/sv2v

LANGUAGE ?= verilog # verilog, vhdl
DESIGN ?= fpu # fpu, lzc

TEST ?= all # f32_mulAdd, f32_add, f32_sub, f32_mul, f32_div, f32_sqrt,
						# f32_le, f32_lt, f32_eq, i32_to_f32, ui32_to_f32, f32_to_i32,
						# f32_to_ui32

generate:
	tests/generate_test_cases.sh tests ${TESTFLOAT} ${PYTHON}

simulation:
	@if [ ${LANGUAGE} = "verilog" ] && [ ${DESIGN} = "fpu" ]; \
	then \
		sim/test_fpu_verilog.sh ${VERILATOR} ${SYSTEMC} ${TEST}; \
	elif [ ${LANGUAGE} = "verilog" ] && [ ${DESIGN} = "lzc" ]; \
	then \
		sim/test_lzc_verilog.sh ${VERILATOR} ${SYSTEMC}; \
	elif [ ${LANGUAGE} = "vhdl" ] && [ ${DESIGN} = "fpu" ]; \
	then \
		sim/test_fpu_vhdl.sh ${GHDL} ${TEST}; \
	elif [ ${LANGUAGE} = "vhdl" ] && [ ${DESIGN} = "lzc" ]; \
	then \
		sim/test_lzc_vhdl.sh ${GHDL}; \
	fi

synthesis:
	synth/synth_fpu_verilog.sh ${SV2V}
	synth/synth_fpu_vhdl.sh ${GHDL}

all: generate simulation synthesis
