library ieee;
use ieee.std_logic_1164.all;


entity sprite is
    generic (
        FRAME_H_RES : natural := 720;
        FRAME_V_RES : natural := 480;
        SPRITE_H_RES : natural := 95;
        SPRITE_V_RES : natural := 95
    );
    port (
        i_clk : in std_logic;
        i_rst_n : in std_logic;

        -- inputs 
        i_x_sprite_pos : natural range 0 to FRAME_H_RES - 1;
        i_y_sprite_pos : natural range 0 to FRAME_V_RES - 1;

        i_x_pixel : natural range 0 to (h_res - 1);
        i_y_pixel : natural range 0 to (v_res - 1);

        -- outputs
        pixel_address : natural range 0 to ((SPRITE_H_RES*SPRITE_V_RES)-1)

    );
end entity sprite;

architecture rtl of sprite is
begin

	process (i_x_pixel, i_y_pixel)
	begin
            if (((i_x_pixel > i_x_sprite_pos) and (i_x_pixel < i_x_sprite_pos + 95)) and ((i_y_pixel > i_y_sprite_pos) and (i_y_pixel < i_y_sprite_pos + 95))) then
				pixel_address <= i_x_pixel-i_x_sprite_pos + (i_y_pixel-i_y_sprite_pos)*95;
			else
				pixel_address <= 0;
			end if;
	end process;

end architecture rtl;