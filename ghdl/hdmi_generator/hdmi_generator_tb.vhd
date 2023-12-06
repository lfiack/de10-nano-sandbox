library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hdmi_generator_tb is
end entity hdmi_generator_tb;

architecture tb of hdmi_generator_tb is
    constant h_res : natural := 720;
    constant v_res : natural := 480;

    constant mem_size : natural := h_res*v_res;
    constant data_width : natural := 8;

    signal clk     : std_logic;
    signal reset_n : std_logic;
    signal hdmi_hs : std_logic;
    signal hdmi_vs : std_logic;
    signal hdmi_de : std_logic;
    signal pixel_en : std_logic;
    signal pixel_address : natural range 0 to (mem_size - 1);

    signal data_in	: std_logic_vector(data_width-1 downto 0);
    signal data_out	: std_logic_vector(data_width-1 downto 0);
    signal addr_in	: natural range 0 to mem_size-1;
    signal we_a	    : std_logic := '0';
    signal we_b	    : std_logic := '0';
    signal q_a		: std_logic_vector(data_width-1 downto 0);
    signal q_b		: std_logic_vector(data_width-1 downto 0);

    signal clk_a : std_logic;

    signal finished : boolean := false;
begin
    data_out <= (others => '0');

	hdmi_0 : entity work.hdmi_generator
        generic map (
            h_res => h_res,
            v_res => v_res,

            h_sync => 61,
            h_fp   => 58,
            h_bp   => 18,

            v_sync => 5,
            v_fp   => 30,
            v_bp   => 9
        )
        port map (
            i_clk     => clk,
            i_reset_n => reset_n,
            o_hdmi_hs => hdmi_hs,
            o_hdmi_vs => hdmi_vs,
            o_hdmi_de => hdmi_de,
            o_pixel_en => pixel_en,
            o_pixel_address => pixel_address
  	    );

    dpram_0 : entity work.dpram
        generic map (
            mem_size => h_res*v_res,
            data_width => 8
        )
        port map (
            i_clk_a  => clk_a,
            i_clk_b  => clk,
            i_data_a => data_in,
            i_data_b => data_out,
            i_addr_a => addr_in,
            i_addr_b => pixel_address,
            i_we_a   => we_a,
            i_we_b   => we_b,
            
            o_q_a    => q_a,
            o_q_b    => q_b
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
        wait for 1000 ns;
        reset_n <= '1';
        wait for 100000 ns;

        finished <= true;
        wait;
    end process p_tb;

    -- p_fill_ram : process
    -- begin
    --     we_a <= '1';
    --     for i in 0 to mem_size-1 loop
    --         addr_in <= i;
    --         data_in <= std_logic_vector(to_unsigned(i, data_width));
    --         clk_a <= '0'; wait for 1 ns;
    --         clk_a <= '1'; wait for 1 ns;
    --     end loop;
    --     we_a <= '0';
    --     wait;
    -- end process p_fill_ram;
end architecture tb;