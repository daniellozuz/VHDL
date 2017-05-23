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
      P1DOWN : in std_logic
	);

  type arr64x48 is array (0 to 63, 0 to 47) of std_logic;
end costam;

architecture Behavioral of costam is
	signal clk25 : std_logic;
	signal vs : std_logic;
	signal hs : std_logic;
  signal px : integer := 0;
  signal py : integer := 0;
  signal screen : arr64x48 := (others => '0');
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
		variable cntv : integer := 0;
	begin
  
		if rising_edge(clk25) then
			if cntv < 1600 then
				vs <= '0';
			else
				vs <= '1';
			end if;

			if cntv = 416800 then
				cntv := 0;
			end if;
			
			cntv := cntv + 1;
		end if;
    
	end process generate_vsync;
	

	generate_hsync : process (clk25)
		variable cnth : integer := 0;
	begin
  
		if rising_edge(clk25) then
			if cnth < 96 then
				hs <= '0';
			else
				hs <= '1';
			end if;
			
			if cnth = 800 then
				cnth := 0;
			end if;
			
			cnth := cnth + 1;
		end if;
    
	end process generate_hsync;
	

  pixel : process (hs)
    variable pix_x : integer := 0;
    variable pix_y : integer := 0;
  begin
  
    if rising_edge(hs) then
      pix_x := (pix_x + 1) mod 640;
      if pix_x = 0 then
        pix_y := (pix_y + 1) mod 480;
      end if;

      px <= pix_x;
      py <= pix_y;
    end if;
    
  end process pixel;


  draw_paddle1 : process (clk25)
    variable pad1Top := 30;
    variable pad1Len := 10;
  begin
    -- Need to add limits
    if P1UP = '1' then
      pad1Top := pad1Top - 1;
    end if;

    if P1DOWN = '1' then
      pad1Top := pad1Top + 1;
    end if;
  
    for i in 0 to 47 loop
      screen(5, i) <= '1' when (i > pad1Top and i <= pad1Top + pad1Len) else '0';
    end loop;
    
    wait for 100 ms;
    
  end process draw_paddle1;


  display : process (clk25)
	begin
  
		if (rising_edge(clk25)) then
			if hs = '1' and vs = '1' then 
				-- display appropriate pixel (coordinates px/10, py/10 of array screen)
        if screen(px/10, py/10) = '1' then
  				VGA_R <= "1111";
  				VGA_G <= "1111";
  				VGA_B <= "1111";
        else
          VGA_R <= "0000";
  				VGA_G <= "0000";
  				VGA_B <= "0000";
        end if;
			else
				-- display 0's
				VGA_R <= "0000";
				VGA_G <= "0000";
				VGA_B <= "0000";
			end if;
			
			HSYNC <= hs;
			VSYNC <= vs;
		end if;
    
	end process display;


end Behavioral;
