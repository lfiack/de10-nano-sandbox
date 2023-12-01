library ieee;
use ieee.std_logic_1164.all;

entity test_led is
	port (
		i_clk_50 : in std_logic;
		i_rst_n : in std_logic;
		
		o_led : out std_logic_vector(7 downto 0)
	);
end entity test_led;

architecture rtl of test_led is
	constant FREQ_DIV : integer := 5000000;
	
	signal r_led : std_logic_vector(7 downto 0) := x"01";
begin
	o_led <= r_led;

	p_k2000: process (i_clk_50, i_rst_n)
		variable count : integer range 0 to FREQ_DIV - 1 := 0;
	begin
		if (i_rst_n = '0') then
			r_led <= x"01";
			count := 0;
		elsif (rising_edge(i_clk_50)) then
			if (count = FREQ_DIV-1) then
				count := 0;
				r_led(0) <= r_led(7);
				r_led(7 downto 1) <= r_led(6 downto 0);
			else
				count := count + 1;
			end if;
		end if;
	end process p_k2000;

end architecture rtl;