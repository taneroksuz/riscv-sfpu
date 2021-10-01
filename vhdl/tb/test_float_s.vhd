-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

use work.lzc_wire.all;
use work.fp_cons.all;
use work.fp_wire.all;
use work.all;

entity test_float_s is
end entity test_float_s;

architecture behavior of test_float_s is

	component fp_unit
		port(
			reset     : in  std_logic;
			clock     : in  std_logic;
			fp_unit_i : in  fp_unit_in_type;
			fp_unit_o : out fp_unit_out_type
		);
	end component;

	type test_state_type is (TEST0, TEST1, TEST2);

	type fpu_test_reg_type is record
		dataread    : std_logic_vector(155 downto 0);
		state       : test_state_type;
		opcode      : std_logic_vector(9 downto 0);
		conv        : std_logic_vector(1 downto 0);
		data1       : std_logic_vector(31 downto 0);
		data2       : std_logic_vector(31 downto 0);
		data3       : std_logic_vector(31 downto 0);
		result      : std_logic_vector(31 downto 0);
		flags       : std_logic_vector(4 downto 0);
		fmt         : std_logic_vector(1 downto 0);
		rm          : std_logic_vector(2 downto 0);
		op          : fp_operation_type;
		result_orig : std_logic_vector(31 downto 0);
		result_calc : std_logic_vector(31 downto 0);
		result_diff : std_logic_vector(31 downto 0);
		flags_orig  : std_logic_vector(4 downto 0);
		flags_calc  : std_logic_vector(4 downto 0);
		flags_diff  : std_logic_vector(4 downto 0);
	end record;

	constant init_fpu_test_reg : fpu_test_reg_type := (
		dataread    => (others => '0'),
		state       => TEST0,
		opcode      => (others => '0'),
		conv        => (others => '0'),
		data1       => (others => '0'),
		data2       => (others => '0'),
		data3       => (others => '0'),
		result      => (others => '0'),
		flags       => (others => '0'),
		fmt         => (others => '0'),
		rm          => (others => '0'),
		op          => init_fp_operation,
		result_orig => (others => '0'),
		result_calc => (others => '0'),
		result_diff => (others => '0'),
		flags_orig  => (others => '0'),
		flags_calc  => (others => '0'),
		flags_diff  => (others => '0')
	);

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	signal r   : fpu_test_reg_type;
	signal rin : fpu_test_reg_type;

	signal fpu_i : fp_unit_in_type;
	signal fpu_o : fp_unit_out_type;

begin

	reset <= '1' after 1 ns;
	clock <= not clock after 1 ns;

	fp_unit_comp : fp_unit
		port map(
			reset     => reset,
			clock     => clock,
			fp_unit_i => fpu_i,
			fp_unit_o => fpu_o
		);

	process(all)
		file infile       : text open read_mode is "fpu.dat";
		variable inline   : line;
		variable dataread : std_logic_vector(155 downto 0);

		variable v : fpu_test_reg_type;

	begin
		v := r;

		case r.state is
			when TEST0 =>
				if reset = '0' then
					fpu_i.fp_exe_i.enable <= '0';
				else
					fpu_i.fp_exe_i.enable <= '1';
					v.state := TEST1;
				end if;
			when TEST1 =>
				if fpu_o.fp_exe_o.ready = '1' then
					v.state := TEST2;
				end if;
				fpu_i.fp_exe_i.enable <= '0';
			when others =>
				v.state := TEST0;
				fpu_i.fp_exe_i.enable <= '0';
		end case;

		case r.state is

			when TEST0 =>

				if endfile(infile) then
					report "TEST SUCCEEDED";
					std.env.finish;
				end if;

				readline(infile, inline);
				hread(inline, dataread);

				v.data1 := dataread(155 downto 124);
				v.data2 := dataread(123 downto 92);
				v.data3 := dataread(91 downto 60);
				v.result := dataread(59 downto 28);
				v.flags := dataread(24 downto 20);
				v.fmt := "00";
				v.rm := dataread(18 downto 16);
				v.conv := dataread(13 downto 12);
				v.opcode := dataread(9 downto 0);

				if reset = '0' then
					v.op := init_fp_operation;
				else
					v.op.fmadd := v.opcode(0);
					v.op.fadd := v.opcode(1);
					v.op.fsub := v.opcode(2);
					v.op.fmul := v.opcode(3);
					v.op.fdiv := v.opcode(4);
					v.op.fsqrt := v.opcode(5);
					v.op.fcmp := v.opcode(6);
					v.op.fcvt_i2f := v.opcode(8);
					v.op.fcvt_f2i := v.opcode(9);
					v.op.fcvt_op := v.conv(1 downto 0);
				end if;

			when TEST1 =>

				v.result_calc := fpu_o.fp_exe_o.result;
				v.flags_calc := fpu_o.fp_exe_o.flags;
				v.result_orig := v.result;
				v.flags_orig := v.flags;

				if (v.op.fcvt_f2i = '0') and (v.result_calc = x"7FC00000") then
					v.result_diff := "0" & (v.result_orig(30 downto 22) xor v.result_calc(30 downto 22)) & "00" & x"00000";
				else
					v.result_diff := v.result_orig xor v.result_calc;
				end if;
				v.flags_diff := v.flags_orig xor v.flags_calc;

				v.op := init_fp_operation;

			when others =>

				if (or v.result_diff = '1') or (or v.flags_diff = '1') then
					report "TEST FAILED" severity warning;
					report "A                 = 0x" & to_hstring(v.data1);
					report "B                 = 0x" & to_hstring(v.data2);
					report "RESULT DIFFERENCE = 0x" & to_hstring(v.result_diff);
					report "RESULT REFERENCE  = 0x" & to_hstring(v.result_orig);
					report "RESULT CALCULATED = 0x" & to_hstring(v.result_calc);
					report "FLAGS DIFFERENCE  = 0x" & to_hstring(v.flags_diff);
					report "FLAGS REFERENCE   = 0x" & to_hstring(v.flags_orig);
					report "FLAGS CALCULATED  = 0x" & to_hstring(v.flags_calc);
					std.env.finish;
				end if;

				v.op := init_fp_operation;

		end case;

		fpu_i.fp_exe_i.data1 <= v.data1;
		fpu_i.fp_exe_i.data2 <= v.data2;
		fpu_i.fp_exe_i.data3 <= v.data3;
		fpu_i.fp_exe_i.op <= v.op;
		fpu_i.fp_exe_i.fmt <= v.fmt;
		fpu_i.fp_exe_i.rm <= v.rm;

		rin <= v;

	end process;

	process(clock)
	begin
		if rising_edge(clock) then

			if reset = '0' then

				r <= init_fpu_test_reg;

			else

				r <= rin;

			end if;

		end if;

	end process;

end architecture;
