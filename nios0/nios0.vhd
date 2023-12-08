library ieee;
use ieee.std_logic_1164.all;

library nios0_ip;
use nios0_ip.nios0_ip;

entity nios0 is
	port (
		i_clk_50 : in std_logic;
		i_reset_n : in std_logic;
		o_leds : out std_logic_vector(7 downto 0)
	);
end entity nios0;

architecture rtl of nios0 is
begin
	nios: entity nios0_ip.nios0_ip
		port map (
			clk_clk => i_clk_50,
        reset_reset_n => i_reset_n,
		  leds_export => o_leds
    );
end architecture rtl;