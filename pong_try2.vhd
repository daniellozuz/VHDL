---------- TO DO ----------
-- check signal timings, adjust counters and VGA signals down to single clock cycle
-- translate variable/signal names into English :)
-- prescaler in paddles
-- ball
-- ball behaviour (movement, wall bouncing, paddle bouncing, out of screen behaviour - score update)
-- score display (division of screen into 2 parts - score and board)
-- start, win, reset
-- make procedures for white/black display
-- consider swapping into array format
-- make records out of objects (point coordinates, paddle sizes, ball characteristics)

---------- OPTIONAL ----------
-- ball speed change
-- paddle length change
-- paddle steering (joystick control / voice control)


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pong is
	Port( CLK : in std_logic;
			VGA_R : out std_logic_vector (3 downto 0);
			VGA_G : out std_logic_vector (3 downto 0);
			VGA_B : out std_logic_vector (3 downto 0);
			VSYNC : out std_logic;
			HSYNC : out std_logic;
			P1UP : in std_logic;
			P1DOWN : in std_logic;
			P2UP : in std_logic;
			P2DOWN : in std_logic );
end pong;

architecture behavioral of pong is
	signal clk25 : std_logic;
	signal vs : std_logic;
	signal hs : std_logic;
	signal disp_en : std_logic;
	signal hcnt : integer := 0;
	signal vcnt : integer := 0;
	signal px : integer := 0;
	signal py : integer := 0;
	
	signal pad1Top : integer := 300;
	signal pad1Len : integer := 100;
	signal pad2Top : integer := 300;
	signal pad2Len : integer := 100;
	
	constant vTs : integer := 416_800;
	constant vTdisp : integer := 384_000;
	constant vTpw : integer := 1_600;
	constant vTfp : integer := 8_000;
	constant vTbp : integer := 23_200;
	
	constant hTs : integer := 800;
	constant hTdisp : integer := 640;
	constant hTpw : integer := 96;
	constant hTfp : integer := 16;
	constant hTbp : integer := 48;
begin


	---------- CLOCK 50 MHz into 25 MHz ----------
	Inst_clock25: entity work.clock25
	port map (
		CLKIN_IN => CLK,
		CLKDV_OUT => clk25,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => open
	);


	---------- VGA SIGNAL CREATION ----------
	generate_vsync : process (clk25)
	begin

		if rising_edge(clk25) then
			if vcnt < vTpw then
				vs <= '0';
			else
				vs <= '1';
			end if;

			if vcnt = vTs - 1 then
				vcnt <= 0;
			else
				vcnt <= vcnt + 1;
			end if;

			VSYNC <= vs;
		end if;

	end process generate_vsync;


	generate_hsync : process (clk25)
	begin

		if rising_edge(clk25) then
			if hcnt < hTpw then
				hs <= '0';
			else
				hs <= '1';
			end if;

			if hcnt = hTs - 1 then
				hcnt <= 0;
			else
				hcnt <= hcnt + 1;
			end if;

			HSYNC <= hs;
		end if;

	end process generate_hsync;

	
	generate_disp_en : process (clk25)
	begin
	
		if hcnt < hTpw + hTbp or hcnt > hTs - hTfp then
			disp_en <= '0';
		else
			disp_en <= '1';
		end if;
	
	end process disp_en;
	
	
	---------- GAME OBJECTS ----------
	paddle1 : process (P1UP, P1DOWN)
	begin
  
		if P1UP = '1' and pad1Top > 0 then
			pad1Top <= pad1Top - 1;
		end if;

		if P1DOWN = '1' and pad1Top + pad1Len < 479 then
			pad1Top <= pad1Top + 1;
		end if;

	end process paddle1;
	
	
	paddle2 : process (P2UP, P2DOWN)
	begin
  
		if P2UP = '1' and pad2Top > 0 then
			pad2Top <= pad2Top - 1;
		end if;

		if P2DOWN = '1' and pad2Top + pad2Len < 479 then
			pad2Top <= pad2Top + 1;
		end if;

  end process paddle2;
	

	---------- PIXEL CALCULATION ----------
	pixel : process (hcnt, vcnt)
	begin
		px <= hcnt - hTpw - hTbp;
		
		if rising_edge(hs) then
			if py = 639 then
				py <= 0;
			else
				py <= py + 1;
			end if;
		end if;
	end process pixel;


	---------- SCREEN IMAGE DISPLAY ----------
	display : process (clk25)
	begin

		if (rising_edge(clk25)) then
			if hs = '1' and vs = '1' and disp_en = '1' then
				if (px > 50 and px < 70 and py > pad1Top and py < pad1Top + pad1Len) or (px > 640 - 50 and px < 640 - 70 and py > pad2Top and py < pad2Top + pad2Len) then
					VGA_R <= "1111"; VGA_G <= "1111"; VGA_B <= "1111";
				else
					VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
				end if;
			else
				VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
			end if;
		end if;

	end process display;


end behavioral;