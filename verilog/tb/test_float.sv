import fp_wire::*;

module test_float
(
	input reset,
	input clock
);
	timeunit 1ns;
	timeprecision 1ps;

	integer data_file;
	integer scan_file;

	logic [155:0] dataread;

	logic [31:0] result_calc;
	logic [4:0] flags_calc;
	logic ready_calc;

	logic [31:0] data1;
	logic [31:0] data2;
	logic [31:0] data3;
	logic [31:0] result;
	logic [4:0] flags;
	logic [1:0] fmt;
	logic [2:0] rm;
	logic [1:0] op;
	logic [9:0] opcode;
	logic enable;

	fp_unit_in_type fp_unit_i;
	fp_unit_out_type fp_unit_o;

	logic [31:0] result_diff;
	logic [4:0] flags_diff;

	initial begin
		data_file = $fopen("fpu.dat", "r");
		if (data_file == 0) begin
			$display("fpu.dat is not available!");
			$finish;
		end
	end

	generate

		always_ff @(posedge clock) begin
			if (!reset) begin
				data1 <= 0;
				data2 <= 0;
				data3 <= 0;
				result <= 0;
				flags <= 0;
				fmt <= 0;
				rm <= 0;
				op <= 0;
				opcode <= 0;
				enable <= 0;
			end else begin
				if ($feof(data_file)) begin
					$display("TEST SUCCEEDED");
					$finish;
				end
				scan_file <= $fscanf(data_file,"%h\n", dataread);
				data1 <= dataread[155:124];
				data2 <= dataread[123:92];
				data3 <= dataread[91:60];
				result <= dataread[59:28];
				flags <= dataread[24:20];
				fmt <= 0;
				rm <= dataread[18:16];
				op <= dataread[13:12];
				opcode <= dataread[9:0];
				enable <= 1;
			end
		end

		assign fp_unit_i.fp_exe_i.data1 = data1;
		assign fp_unit_i.fp_exe_i.data2 = data2;
		assign fp_unit_i.fp_exe_i.data3 = data3;
		assign fp_unit_i.fp_exe_i.fmt = fmt;
		assign fp_unit_i.fp_exe_i.rm = rm;
		assign fp_unit_i.fp_exe_i.op.fmadd = opcode[0];
		assign fp_unit_i.fp_exe_i.op.fmsub = 0;
		assign fp_unit_i.fp_exe_i.op.fnmadd = 0;
		assign fp_unit_i.fp_exe_i.op.fnmsub = 0;
		assign fp_unit_i.fp_exe_i.op.fadd = opcode[1];
		assign fp_unit_i.fp_exe_i.op.fsub = opcode[2];
		assign fp_unit_i.fp_exe_i.op.fmul = opcode[3];
		assign fp_unit_i.fp_exe_i.op.fdiv = opcode[4];
		assign fp_unit_i.fp_exe_i.op.fsqrt = opcode[5];
		assign fp_unit_i.fp_exe_i.op.fsgnj = 0;
		assign fp_unit_i.fp_exe_i.op.fcmp = opcode[6];
		assign fp_unit_i.fp_exe_i.op.fmax = 0;
		assign fp_unit_i.fp_exe_i.op.fclass = 0;
		assign fp_unit_i.fp_exe_i.op.fmv_i2f = 0;
		assign fp_unit_i.fp_exe_i.op.fmv_f2i = 0;
		assign fp_unit_i.fp_exe_i.op.fcvt_i2f = opcode[8];
		assign fp_unit_i.fp_exe_i.op.fcvt_f2i = opcode[9];
		assign fp_unit_i.fp_exe_i.op.fcvt_op = op;
		assign fp_unit_i.fp_exe_i.enable = enable;

		fp_unit fp_unit_comp
		(
			.reset ( reset ),
			.clock ( clock ),
			.fp_unit_i ( fp_unit_i ),
			.fp_unit_o ( fp_unit_o )
		);

		assign result_calc = fp_unit_o.fp_exe_o.result;
		assign flags_calc = fp_unit_o.fp_exe_o.flags;
		assign ready_calc = fp_unit_o.fp_exe_o.ready;

		always_ff @(posedge clock) begin

			if (~reset) begin

			end else begin
				if (opcode[9] == 0 & result_calc[31:0] == 32'h7FC00000) begin
					result_diff = {1'h0,result_calc[30:22] ^ result[30:22],22'h0};
				end else begin
					result_diff = result_calc ^ result;
				end
				if (ready_calc) begin
					flags_diff = flags_calc ^ flags;
					if ((result_diff != 0) || (flags_diff != 0)) begin
						$display("TEST FAILED");
						$display("CLOCKS: %t",$time);
						$display("data1: 0x%h \n",data1);
						$display("data2: 0x%h \n",data2);
						$display("data3: 0x%h \n",data3);
						$display("rm: %b \n",rm);
						$display("opcode: %b \n",opcode);
						$display("result: expected -> 0x%h calculated -> 0x%h difference -> 0x%h \n",result,result_calc,result_diff);
						$display("flags: expected -> %b calculated -> %b difference -> %b \n",flags,flags_calc,flags_diff);
						$display("wrong result");
						$finish;
					end
				end
			end

		end

	endgenerate

endmodule
