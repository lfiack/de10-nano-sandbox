library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_generator_tb is
end entity hdmi_generator_tb;

architecture tb of hdmi_generator_tb is
    signal clk     : std_logic;
    signal reset_n : std_logic;
    signal hdmi_hs : std_logic;
    signal hdmi_vs : std_logic;
    signal hdmi_de : std_logic;
    signal hdmi_r  : std_logic_vector(7 downto 0);
    signal hdmi_g  : std_logic_vector(7 downto 0);
    signal hdmi_b  : std_logic_vector(7 downto 0);

    signal finished : boolean := false;
begin
	hdmi_0 : entity work.hdmi_generator
        port map (
            clk     => clk,
            reset_n => reset_n,
            hdmi_hs => hdmi_hs,
            hdmi_vs => hdmi_vs,
            hdmi_de => hdmi_de,
            hdmi_r  => hdmi_r,
            hdmi_g  => hdmi_g,
            hdmi_b  => hdmi_b
  	    );

    p_clk : process
    begin
        if (finished = true) then
            wait;
        else
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end if;
    end process p_clk;

    p_tb : process
    begin
        reset_n <= '0';
        wait for 100 ns;
        reset_n <= '1';
        wait for 1000 ns;

        finished <= true;
        wait;
    end process p_tb;
end architecture tb;