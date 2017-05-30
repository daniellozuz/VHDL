library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity costam is
	Port( CLK : in std_logic;
			VGA_R : out std_logic_vector (3 downto 0);
			VGA_G : out std_logic_vector (3 downto 0);
			VGA_B : out std_logic_vector (3 downto 0);
			VSYNC : out std_logic;
			HSYNC : out std_logic;
			P1UP : in std_logic;
			P1DOWN : in std_logic );
end costam;

architecture Behavioral of costam is
	signal clk25 : std_logic;
	signal vs : std_logic;
	signal hs : std_logic;
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
	begin

		if rising_edge(clk25) then
			if cntv < 24_800 then
				vs <= '0';
			else if cntv > 408_800 then
				vs <= '0';
			else
				vs <= '1';
			end if;

			if cntv = 416_800 then
				cntv <= 0;
			end if;

			cntv <= cntv + 1;
		end if;

	end process generate_vsync;


	generate_hsync : process (clk25)
	begin

		if rising_edge(clk25) then
			if cnth < 144 then
				hs <= '0';
			else if cnth > 784 then
				hs <= '0';
			else
				hs <= '1';
			end if;

			if cnth = 800 then
				cnth <= 0;
			end if;

			cnth <= cnth + 1;
		end if;

	end process generate_hsync;


  pixel : process (cnth, cntv)
	begin
		px <= cnth - 140;
		
		if rising_edge(hs) then
			if py = 639 then
				py <= 0;
			else
				py <= py + 1;
			end if;
		end if;
  end process pixel;


  paddle1 : process (P1UP, P1DOWN)
		variable last_change : time := 0 ns;
	begin
  
		if (now - last_change > 100 ms) then
			last_change := now;
			-- Need to add limits
			if P1UP = '1' and pad1Top > 0 then
				pad1Top <= pad1Top - 1;
			end if;

			if P1DOWN = '1' and pad1Top + pad1Len < 479 then
				pad1Top <= pad1Top + 1;
			end if;
		end if;

  end process paddle1;
	
	
	paddle2 : process (P2UP, P2DOWN)
  	variable last_change : time := 0 ns;
	begin
  
		if (now - last_change > 100 ms) then
			last_change := now;
			-- Need to add limits
			if P2UP = '1' and pad2Top > 0 then
				pad2Top <= pad2Top - 1;
			end if;

			if P2DOWN = '1' and pad2Top + pad2Len < 479 then
				pad2Top <= pad2Top + 1;
			end if;
		end if;

  end process paddle2;


	display : process (clk25)
	begin

		if (rising_edge(clk25)) then
			if hs = '1' and vs = '1' then
				if (px > 50 and px < 70 and py > pad1Top and py < pad1Top + pad1Len) or (px > 570 and px < 590 and py > pad2Top and py < pad2Top + pad2Len) then
					-- A procedure to show black or white?
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