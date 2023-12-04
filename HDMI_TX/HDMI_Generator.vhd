library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HDMI_Generator is
  Port (
    clk      : in STD_LOGIC;
    reset_n  : in STD_LOGIC;
    hdmi_hs   : out STD_LOGIC;
    hdmi_vs   : out STD_LOGIC;
    hdmi_de   : out STD_LOGIC;
    hdmi_r    : out STD_LOGIC_VECTOR(7 downto 0);
    hdmi_g    : out STD_LOGIC_VECTOR(7 downto 0);
    hdmi_b    : out STD_LOGIC_VECTOR(7 downto 0)
  );
end HDMI_Generator;

architecture rtl of HDMI_Generator is

  -- Signal declarations
  signal h_count   : UNSIGNED(11 downto 0);
  signal v_count   : UNSIGNED(11 downto 0);
  signal h_act     : STD_LOGIC;
  signal v_act     : STD_LOGIC;

  -- Magic values for 720p
  constant h_total: INTEGER := 857;
  constant h_sync : INTEGER := 61;
  constant h_start: INTEGER := 119;
  constant h_end  : INTEGER := 839;

  constant v_total: INTEGER := 524;
  constant v_sync : INTEGER := 5;
  constant v_start: INTEGER := 35;
  constant v_end  : INTEGER := 515;
begin
  -- Horizontal control signals
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      h_count   <= (others => '0');
      hdmi_hs    <= '1';
      h_act     <= '0';
    elsif rising_edge(clk) then
      if (to_integer(h_count) = h_total) then
        h_count <= (others => '0');
      else
        h_count <= h_count + 1;
      end if;

      if ((h_count >= h_sync) and (h_count /= h_total)) then
        hdmi_hs <= '1';
      else
        hdmi_hs <= '0';
      end if;

      if (to_integer(h_count) = h_start) then
        h_act <= '1';
      elsif (to_integer(h_count) = h_end) then
        h_act <= '0';
      end if;
    end if;
  end process;

  -- Vertical control signals
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      v_count <= (others => '0');
      hdmi_vs  <= '1';
      v_act   <= '0';
    elsif rising_edge(clk) then
      if (to_integer(h_count) = h_total) then
        if (to_integer(v_count) = v_total) then
          v_count <= (others => '0');
        else
          v_count <= v_count + 1;
        end if;

        if ((v_count >= v_sync) and (v_count /= v_total)) then
          hdmi_vs <= '1';
        else
          hdmi_vs <= '0';
        end if;

        if (to_integer(v_count) = v_start) then
          v_act <= '1';
        elsif (to_integer(v_count) = v_end) then
          v_act <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Display enable and dummy pixels
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      hdmi_de <= '0';
    elsif rising_edge(clk) then
      hdmi_de <= v_act and h_act;

      -- Dummy pixels
      hdmi_r <= std_logic_vector(h_count(7 downto 0));
      hdmi_g <= std_logic_vector(v_count(7 downto 0));
      hdmi_b <= (others => '0');
    end if;
  end process;

end architecture rtl;