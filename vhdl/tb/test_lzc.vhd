-- args: --std=08 --ieee=synopsys

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.lzc_lib.all;

entity test_lzc is
	generic(
		XLEN : natural := 128;
		XLOG : natural := 7
	);
end entity test_lzc;

architecture behavior of test_lzc is

	signal reset : std_logic := '0';
	signal clock : std_logic := '0';

	signal a : std_logic_vector(XLEN - 1 downto 0);
	signal z : std_logic_vector(XLOG - 1 downto 0) := (others => '0');
	signal v : std_logic;

	signal counter : integer := XLEN - 1;

	constant msb : std_logic_vector(XLEN - 1 downto 0) := "1" & (XLEN - 2 downto 0 => '0');
	constant lsb : std_logic_vector(XLEN - 1 downto 0) := (XLEN - 1 downto 1 => '0') & "1";

begin

	reset <= '1' after 1 ns;
	clock <= not clock after 1 ns;

	process(reset, clock)
	begin
		if reset = '0' then

			a       <= lsb;
			counter <= XLEN - 1;

		elsif rising_edge(clock) then

			if (a = msb) then
				report "TEST SUCCEEDED";
				std.env.finish;
			end if;

			if (counter /= to_integer(unsigned(not z))) then
				report "TEST FAILED" severity warning;
			end if;

			a       <= std_logic_vector(shift_left(unsigned(a), 1));
			counter <= counter - 1;

		end if;

	end process;

	lzc_4_gen : if XLEN = 4 generate
		lzc_comp : lzc_4 port map(A => a, Z => z, V => v);
	end generate lzc_4_gen;
	lzc_8_gen : if XLEN = 8 generate
		lzc_comp : lzc_8 port map(A => a, Z => z, V => v);
	end generate lzc_8_gen;
	lzc_16_gen : if XLEN = 16 generate
		lzc_comp : lzc_16 port map(A => a, Z => z, V => v);
	end generate lzc_16_gen;
	lzc_32_gen : if XLEN = 32 generate
		lzc_comp : lzc_32 port map(A => a, Z => z, V => v);
	end generate lzc_32_gen;
	lzc_64_gen : if XLEN = 64 generate
		lzc_comp : lzc_64 port map(A => a, Z => z, V => v);
	end generate lzc_64_gen;
	lzc_128_gen : if XLEN = 128 generate
		lzc_comp : lzc_128 port map(A => a, Z => z, V => v);
	end generate lzc_128_gen;

end architecture;
