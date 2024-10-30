library ieee;
use ieee.std_logic_1164.all;

entity vdsnth_bringup is
	port (
		i_clk : in std_logic;
		i_rst_n : in std_logic;
		o_led : out std_logic_vector(7 downto 0);
		o_vd_led : out std_logic_vector(9 downto 0)
	);
end entity vdsnth_bringup;

architecture rtl of vdsnth_bringup is
	constant freq_div : natural := 5000000;

	signal en_10hz : std_logic;
	
	signal r_counter : natural range 0 to freq_div := 0;
	signal r_led : std_logic_vector(7 downto 0) := "00000001";
	signal r_vd_led : std_logic_vector(9 downto 0) := "0000000001";
begin
	process(i_clk, i_rst_n)
	begin
		if (i_rst_n = '0') then
			r_counter <= 0;
		elsif rising_edge(i_clk) then
			if (r_counter = freq_div) then
				r_counter <= 0;
			else
				r_counter <= r_counter + 1;
			end if;
		end if;
	end process;
	
	en_10hz <= '1' when r_counter = 0 else '0';

	process(i_clk, i_rst_n)
	begin
		if (i_rst_n = '0') then
			r_vd_led <= "0000000001";
		elsif rising_edge(i_clk) then
			if (en_10hz = '1') then
				r_vd_led(9 downto 1) <= r_vd_led(8 downto 0);
				r_vd_led(0) <= r_vd_led(9);
			end if;
		end if;
	end process;
	
	o_led <= r_led;
	o_vd_led <= r_vd_led;
	
	process(i_clk, i_rst_n)
	begin
		if (i_rst_n = '0') then
			r_led <= "00000001";
		elsif rising_edge(i_clk) then
			if (en_10hz = '1') then
				r_led(7 downto 1) <= r_led(6 downto 0);
				r_led(0) <= r_led(7);
			end if;
		end if;
	end process;

end architecture rtl;