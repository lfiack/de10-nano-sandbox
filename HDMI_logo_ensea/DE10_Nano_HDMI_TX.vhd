library ieee;
use ieee.std_logic_1164.all;

library pll;
use pll.all;

entity DE10_Nano_HDMI_TX is
    port (
        -- ADC
        ADC_CONVST         : out STD_LOGIC;
        ADC_SCK            : out STD_LOGIC;
        ADC_SDI            : out STD_LOGIC;
        ADC_SDO            : in STD_LOGIC;

        -- ARDUINO
        ARDUINO_IO         : inout STD_LOGIC_VECTOR(15 downto 0);
        ARDUINO_RESET_N    : inout STD_LOGIC;

        -- FPGA
        FPGA_CLK1_50       : in STD_LOGIC;
        FPGA_CLK2_50       : in STD_LOGIC;
        FPGA_CLK3_50       : in STD_LOGIC;

        -- GPIO
        GPIO_0             : inout STD_LOGIC_VECTOR(35 downto 0);
        GPIO_1             : inout STD_LOGIC_VECTOR(35 downto 0);

        -- HDMI
        HDMI_I2C_SCL       : inout STD_LOGIC;
        HDMI_I2C_SDA       : inout STD_LOGIC;
        HDMI_I2S           : inout STD_LOGIC;
        HDMI_LRCLK         : inout STD_LOGIC;
        HDMI_MCLK          : inout STD_LOGIC;
        HDMI_SCLK          : inout STD_LOGIC;
        HDMI_TX_CLK        : out STD_LOGIC;
        HDMI_TX_D          : out STD_LOGIC_VECTOR(23 downto 0);
        HDMI_TX_DE         : out STD_LOGIC;
        HDMI_TX_HS         : out STD_LOGIC;
        HDMI_TX_INT        : in STD_LOGIC;
        HDMI_TX_VS         : out STD_LOGIC;

        -- KEY
        KEY                : in STD_LOGIC_VECTOR(1 downto 0);

        -- LED
        LED                : out STD_LOGIC_VECTOR(7 downto 0);

        -- SW
        SW                 : in STD_LOGIC_VECTOR(3 downto 0)
    );
end entity DE10_Nano_HDMI_TX;

architecture rtl of DE10_Nano_HDMI_TX is
	component I2C_HDMI_Config 
		port (
			iCLK : in std_logic;
			iRST_N : in std_logic;
			I2C_SCLK : out std_logic;
			I2C_SDAT : inout std_logic;
			HDMI_TX_INT  : in std_logic
		);
	 end component;
	 
	component pll 
		port (
			refclk : in std_logic;
			rst : in std_logic;
			outclk_0 : out std_logic;
			locked : out std_logic
		);
	end component;

    constant h_res : natural := 720;
    constant v_res : natural := 480;

    constant mem_size : natural := h_res*v_res;
    constant data_width : natural := 8;
	 
	 signal clk_a : std_logic;

	signal vpg_pclk : std_logic;		-- 27MHz
	signal reset_n : std_logic;
	signal gen_clk_locked : std_logic;
	
	signal pixel_en : std_logic;
   signal pixel_address : natural range 0 to (mem_size - 1);
	
	signal new_frame : std_logic;
	signal dot_x_counter : natural range 0 to (h_res - 1);
	signal dot_y_counter : natural range 0 to (v_res - 1);
	signal x_counter : natural range 0 to (h_res - 1);
	signal y_counter : natural range 0 to (v_res - 1);
	
	signal pixel : std_logic_vector(data_width-1 downto 0);
	
	signal r_led : std_logic := '0';
begin
	reset_n <= KEY(0);
	HDMI_TX_CLK <= vpg_pclk;
	
	process (vpg_pclk, gen_clk_locked)
	begin
		if (gen_clk_locked = '0') then
			r_led <= '0';
		elsif (rising_edge(vpg_pclk)) then
			if (new_frame = '1') then
				r_led <= not r_led;
			end if;
		end if;
	end process;
	
	LED(0) <= r_led;
	
--	HDMI_TX_D(23 downto 16) <= pixel;
--	HDMI_TX_D(15 downto 8) <= pixel;
--	HDMI_TX_D(7 downto 0) <= pixel;

	-- increment the dot at each new frame
	process (vpg_pclk, gen_clk_locked)
	begin
		if (gen_clk_locked = '0') then
			dot_x_counter <= 0;
			dot_y_counter <= 0;
		elsif (rising_edge(vpg_pclk)) then
			if (new_frame = '1') then
				-- x/y counter
				if (dot_x_counter >= h_res - 1) then
					dot_x_counter <= 0;
					
					if (dot_y_counter >= v_res -1) then
						dot_y_counter <= 0;
					else
						dot_y_counter <= dot_y_counter + 16;
					end if;
				else
					dot_x_counter <= dot_x_counter + 8;
				end if;
			end if;
		end if;
	end process;
	
	HDMI_TX_D <= (others => '1') when 
	(
		((x_counter > dot_x_counter) and (x_counter < dot_x_counter + 16)) and
		((y_counter > dot_y_counter) and (y_counter < dot_y_counter + 16))
	)
	else (others => '0');
	
	pll0 : component pll 
		port map (
			refclk => FPGA_CLK2_50,
			rst => not(reset_n),
			outclk_0 => vpg_pclk,
			locked => gen_clk_locked
		);
		
	hdmi_generator0 : entity work.hdmi_generator 
		port map (                                    
			i_clk => vpg_pclk,
			i_reset_n => gen_clk_locked,
			o_hdmi_hs => HDMI_TX_HS,
			o_hdmi_vs => HDMI_TX_VS,
			o_hdmi_de => HDMI_TX_DE,
			o_pixel_en => open,
			o_pixel_address => pixel_address,
			o_x_counter => x_counter,
			o_y_counter => y_counter,
			o_new_frame => new_frame
		);
		
--	dpram_0 : entity work.dpram
--		generic map (
--			mem_size => h_res*v_res,
--			data_width => 8
--		)
--		port map (
--			i_clk_a  => clk_a,
--			i_clk_b  => vpg_pclk,
--			i_data_a => (others => '0'),
--			i_data_b => (others => '0'),
--			i_addr_a => 0,
--			i_addr_b => pixel_address,
--			i_we_a   => '0',
--			i_we_b   => '0',
--
--			o_q_a    => open,
--			o_q_b    => pixel
--		);
	
	I2C_HDMI_Config0 : component I2C_HDMI_Config 
		port map (
			iCLK => FPGA_CLK1_50,
			iRST_N => reset_n,
			I2C_SCLK => HDMI_I2C_SCL,
			I2C_SDAT => HDMI_I2C_SDA,
			HDMI_TX_INT => HDMI_TX_INT
	 );
end architecture rtl;