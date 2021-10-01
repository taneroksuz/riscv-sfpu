-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_wire.all;
use work.lzc_lib.all;
use work.fp_cons.all;
use work.fp_wire.all;
use work.fp_lib.all;

entity fp_unit is
	port(
		reset     : in  std_logic;
		clock     : in  std_logic;
		fp_unit_i : in  fp_unit_in_type;
		fp_unit_o : out fp_unit_out_type
	);
end fp_unit;

architecture behavior of fp_unit is

	signal lzc1_32_i : lzc_32_in_type;
	signal lzc1_32_o : lzc_32_out_type;
	signal lzc2_32_i : lzc_32_in_type;
	signal lzc2_32_o : lzc_32_out_type;
	signal lzc3_32_i : lzc_32_in_type;
	signal lzc3_32_o : lzc_32_out_type;
	signal lzc4_32_i : lzc_32_in_type;
	signal lzc4_32_o : lzc_32_out_type;

	signal lzc_128_i : lzc_128_in_type;
	signal lzc_128_o : lzc_128_out_type;

	signal fp_ext1_i : fp_ext_in_type;
	signal fp_ext1_o : fp_ext_out_type;
	signal fp_ext2_i : fp_ext_in_type;
	signal fp_ext2_o : fp_ext_out_type;
	signal fp_ext3_i : fp_ext_in_type;
	signal fp_ext3_o : fp_ext_out_type;

	signal fp_cmp_o  : fp_cmp_out_type;
	signal fp_cmp_i  : fp_cmp_in_type;
	signal fp_max_o  : fp_max_out_type;
	signal fp_max_i  : fp_max_in_type;
	signal fp_sgnj_o : fp_sgnj_out_type;
	signal fp_sgnj_i : fp_sgnj_in_type;
	signal fp_fma_i  : fp_fma_in_type;
	signal fp_fma_o  : fp_fma_out_type;

	signal fp_mac_i : fp_mac_in_type;
	signal fp_mac_o : fp_mac_out_type;

	signal fp_fdiv_i : fp_fdiv_in_type;
	signal fp_fdiv_o : fp_fdiv_out_type;

	signal fp_cvt_f2i_o : fp_cvt_f2i_out_type;
	signal fp_cvt_f2i_i : fp_cvt_f2i_in_type;
	signal fp_cvt_i2f_o : fp_cvt_i2f_out_type;
	signal fp_cvt_i2f_i : fp_cvt_i2f_in_type;

	signal fp_rnd_i : fp_rnd_in_type;
	signal fp_rnd_o : fp_rnd_out_type;

begin

	lzc1_32_comp : lzc_32
		port map(
			A => lzc1_32_i.a,
			Z => lzc1_32_o.c
		);

	lzc2_32_comp : lzc_32
		port map(
			A => lzc2_32_i.a,
			Z => lzc2_32_o.c
		);

	lzc3_32_comp : lzc_32
		port map(
			A => lzc3_32_i.a,
			Z => lzc3_32_o.c
		);

	lzc4_32_comp : lzc_32
		port map(
			A => lzc4_32_i.a,
			Z => lzc4_32_o.c
		);

	lzc_128_comp : lzc_128
		port map(
			A => lzc_128_i.a,
			Z => lzc_128_o.c
		);

	fp_ext1_comp : fp_ext
		port map(
			fp_ext_i => fp_ext1_i,
			fp_ext_o => fp_ext1_o,
			lzc_o    => lzc1_32_o,
			lzc_i    => lzc1_32_i
		);

	fp_ext2_comp : fp_ext
		port map(
			fp_ext_i => fp_ext2_i,
			fp_ext_o => fp_ext2_o,
			lzc_o    => lzc2_32_o,
			lzc_i    => lzc2_32_i
		);

	fp_ext3_comp : fp_ext
		port map(
			fp_ext_i => fp_ext3_i,
			fp_ext_o => fp_ext3_o,
			lzc_o    => lzc3_32_o,
			lzc_i    => lzc3_32_i
		);

	fp_cmp_comp : fp_cmp
		port map(
			fp_cmp_i => fp_cmp_i,
			fp_cmp_o => fp_cmp_o
		);

	fp_rnd_comp : fp_rnd
		port map(
			fp_rnd_i => fp_rnd_i,
			fp_rnd_o => fp_rnd_o
		);

	fp_cvt_comp : fp_cvt
		port map(
			fp_cvt_f2i_i => fp_cvt_f2i_i,
			fp_cvt_f2i_o => fp_cvt_f2i_o,
			fp_cvt_i2f_i => fp_cvt_i2f_i,
			fp_cvt_i2f_o => fp_cvt_i2f_o,
			lzc_i        => lzc4_32_i,
			lzc_o        => lzc4_32_o
		);

	fp_sgnj_comp : fp_sgnj
		port map(
			fp_sgnj_i => fp_sgnj_i,
			fp_sgnj_o => fp_sgnj_o
		);

	fp_max_comp : fp_max
		port map(
			fp_max_i => fp_max_i,
			fp_max_o => fp_max_o
		);

	fp_fma_comp : fp_fma
		port map(
			reset    => reset,
			clock    => clock,
			fp_fma_i => fp_fma_i,
			fp_fma_o => fp_fma_o,
			lzc_o    => lzc_128_o,
			lzc_i    => lzc_128_i
		);

	fp_mac_comp : fp_mac
		port map(
			fp_mac_i => fp_mac_i,
			fp_mac_o => fp_mac_o
		);

	fp_fdiv_comp : fp_fdiv
		port map(
			reset     => reset,
			clock     => clock,
			fp_fdiv_i => fp_fdiv_i,
			fp_fdiv_o => fp_fdiv_o,
			fp_mac_i  => fp_mac_i,
			fp_mac_o  => fp_mac_o
		);

	fp_exe_comp : fp_exe
		port map(
			reset        => reset,
			clock        => clock,
			fp_exe_i     => fp_unit_i.fp_exe_i,
			fp_exe_o     => fp_unit_o.fp_exe_o,
			fp_ext1_o    => fp_ext1_o,
			fp_ext1_i    => fp_ext1_i,
			fp_ext2_o    => fp_ext2_o,
			fp_ext2_i    => fp_ext2_i,
			fp_ext3_o    => fp_ext3_o,
			fp_ext3_i    => fp_ext3_i,
			fp_cmp_o     => fp_cmp_o,
			fp_cmp_i     => fp_cmp_i,
			fp_cvt_f2i_o => fp_cvt_f2i_o,
			fp_cvt_f2i_i => fp_cvt_f2i_i,
			fp_cvt_i2f_o => fp_cvt_i2f_o,
			fp_cvt_i2f_i => fp_cvt_i2f_i,
			fp_max_o     => fp_max_o,
			fp_max_i     => fp_max_i,
			fp_sgnj_o    => fp_sgnj_o,
			fp_sgnj_i    => fp_sgnj_i,
			fp_fma_o     => fp_fma_o,
			fp_fma_i     => fp_fma_i,
			fp_fdiv_o    => fp_fdiv_o,
			fp_fdiv_i    => fp_fdiv_i,
			fp_rnd_o     => fp_rnd_o,
			fp_rnd_i     => fp_rnd_i
		);

end architecture;
