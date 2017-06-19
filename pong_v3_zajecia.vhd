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

architecture Behavioral of pong is
	signal clk25 : std_logic;
	signal vs : std_logic;
	signal hs : std_logic;
	signal disp_en_h : std_logic;
	signal disp_en_v : std_logic;
	signal cnth : integer := 0;
	signal cntv : integer := 0;
	signal px : integer := 0;
	signal py : integer := 0;
	
	signal pad1Top : integer := 300;
	signal pad1Len : integer := 100;
	signal pad2Top : integer := 300;
	signal pad2Len : integer := 100;
begin


	Inst_clock25: entity work.clock25
	port map (
		CLKIN_IN => CLK,
		CLKDV_OUT => clk25,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		LOCKED_OUT => open
	);


	generate_vsync : process (clk25)
		variable cnt : integer := 0;
	begin

		if rising_edge(clk25) then
		
			if cntv < 1_600 then
				vs <= '0';
			else
				vs <= '1';
			end if;

			if cntv = 416_799 then
				cntv <= 0;
			else
				cntv <= cntv + 1;
			end if;
			
			if cntv > 24_800 and cntv < 408_800 then
				cnt := cnt + 1;
				if cnt = 800 then
					cnt := 0;
					py <= py + 1;
				end if;
			else
				py <= 0;
			end if;

		end if;

	end process generate_vsync;


	generate_hsync : process (clk25)
	begin

		if rising_edge(clk25) then
			
			if cnth < 96 then
				hs <= '0';
			else
				hs <= '1';
			end if;

			if cnth = 799 then
				cnth <= 0;
			else
				cnth <= cnth + 1;
			end if;
			
			px <= cnth - 144;

		end if;

	end process generate_hsync;

	
	generate_disp_en_h : process (clk25)
	begin
	
		if cnth < 144 or cnth > 784 then
			disp_en_h <= '0';
		else
			disp_en_h <= '1';
		end if;
	
	end process generate_disp_en_h;
	
	
	generate_disp_en_v : process (clk25)
	begin
	
		if cntv < 24_800 or cntv > 408_800 then
			disp_en_v <= '0';
		else
			disp_en_v <= '1';
		end if;
	
	end process generate_disp_en_v;


	paddle1 : process (clk25)
		variable presc : integer := 0;
	begin
  
		if P1UP = '1' and pad1Top > 0 and presc > 10_000_000 then
			pad1Top <= pad1Top - 1;
			presc := 0;
		end if;

		if P1DOWN = '1' and pad1Top + pad1Len < 479 and presc > 10_000_000 then
			pad1Top <= pad1Top + 1;
			presc := 0;
		end if;
		
		presc := presc + 1;

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


	display : process (clk25)
	begin

		if (rising_edge(clk25)) then
			if disp_en_h = '1' and disp_en_v = '1' then
				if (px > 50 and px < 70 and py > pad1Top and py < pad1Top + pad1Len) or (px > 640 - 50 and px < 640 - 70 and py > pad2Top and py < pad2Top + pad2Len) then
					VGA_R <= "1111"; VGA_G <= "1111"; VGA_B <= "1111";
				else
					VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
				end if;
			else
				VGA_R <= "0000"; VGA_G <= "0000"; VGA_B <= "0000";
			end if;

			HSYNC <= hs;
			VSYNC <= vs;
		end if;

	end process display;


end Behavioral;