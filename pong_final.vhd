-- Wiecej stref odbijania
-- Punkty
-- Ladniejszy kod
-- Randomowy poczatkowy kierunek

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pong is
	Port( CLK : 	in std_logic;
			VGA_R : 	out std_logic_vector (3 downto 0);
			VGA_G : 	out std_logic_vector (3 downto 0);
			VGA_B : 	out std_logic_vector (3 downto 0);
			VSYNC : 	out std_logic;
			HSYNC : 	out std_logic;
			P1UP : 	in std_logic;
			P1DOWN : in std_logic;
			P2UP : 	in std_logic;
			P2DOWN : in std_logic );
end pong;

architecture behavioral of pong is
	signal clk25 : 		std_logic;
	signal vs : 			std_logic;
	signal hs : 			std_logic;
	signal disp_en_h : 	std_logic;
	signal disp_en_v : 	std_logic;
	signal cnth : 			integer 		:= 0;
	signal cntv : 			integer 		:= 0;
	signal px : 			integer 		:= 0;
	signal py : 			integer 		:= 0;
	
	signal pad1Top : 		integer 		:= 300;
	signal pad1Len : 		integer 		:= 100;
	signal pad2Top : 		integer 		:= 300;
	signal pad2Len : 		integer 		:= 100;
	
	signal bx :				integer		:= 310;
	signal by :				integer		:= 230;
	signal bsize :			integer		:= 20;
	
	signal sc1 :			integer		:= 0;
	signal sc2 :			integer		:= 0;

	function show_score (px, py, dig_pos_x, dig_pos_y, sc : integer) return bit is
		variable white : bit := '0';
	begin
	
		if ( px > dig_pos_x 			and px < dig_pos_x + 10 	and py > dig_pos_y 			and py < dig_pos_y + 10 	and ( sc = 0 or 			  sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 10 	and px < dig_pos_x + 20 	and py > dig_pos_y 			and py < dig_pos_y + 10 	and ( sc = 0 or 			  sc = 2 or sc = 3 or 			  sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 20 	and px < dig_pos_x + 30 	and py > dig_pos_y 			and py < dig_pos_y + 10 	and ( sc = 0 or sc = 1 or sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
	
		if ( px > dig_pos_x 			and px < dig_pos_x + 10 	and py > dig_pos_y + 10 	and py < dig_pos_y + 20 	and ( sc = 0 or 			  							 sc = 4 or sc = 5 or sc = 6 or 			  sc = 8 or sc = 9 ) ) then white := '1'; end if;
		
		if ( px > dig_pos_x + 20 	and px < dig_pos_x + 30 	and py > dig_pos_y + 10 	and py < dig_pos_y + 20 	and ( sc = 0 or sc = 1 or sc = 2 or sc = 3 or sc = 4 or  						 sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
	
		if ( px > dig_pos_x 			and px < dig_pos_x + 10 	and py > dig_pos_y + 20		and py < dig_pos_y + 30 	and ( sc = 0 or 			  sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or 			  sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 10 	and px < dig_pos_x + 20 	and py > dig_pos_y + 20		and py < dig_pos_y + 30 	and ( 			 			  sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or			  sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 20 	and px < dig_pos_x + 30 	and py > dig_pos_y + 20		and py < dig_pos_y + 30 	and ( sc = 0 or sc = 1 or sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
	
		if ( px > dig_pos_x 			and px < dig_pos_x + 10 	and py > dig_pos_y + 30		and py < dig_pos_y + 40 	and ( sc = 0 or 			  sc = 2 or 			 			  				sc = 6 or 			  sc = 8				 ) ) then white := '1'; end if;
		
		if ( px > dig_pos_x + 20 	and px < dig_pos_x + 30 	and py > dig_pos_y + 30		and py < dig_pos_y + 40 	and ( sc = 0 or sc = 1 or 				sc = 3 or sc = 4 or sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
		
		if ( px > dig_pos_x 			and px < dig_pos_x + 10 	and py > dig_pos_y + 40		and py < dig_pos_y + 50 	and ( sc = 0 or 			  sc = 2 or sc = 3 or 			  sc = 5 or sc = 6 or 			  sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 10 	and px < dig_pos_x + 20 	and py > dig_pos_y + 40		and py < dig_pos_y + 50 	and ( sc = 0 or 			  sc = 2 or sc = 3 or 			  sc = 5 or sc = 6 or			  sc = 8 or sc = 9 ) ) then white := '1'; end if;
		if ( px > dig_pos_x + 20 	and px < dig_pos_x + 30 	and py > dig_pos_y + 40		and py < dig_pos_y + 50 	and ( sc = 0 or sc = 1 or sc = 2 or sc = 3 or sc = 4 or sc = 5 or sc = 6 or sc = 7 or sc = 8 or sc = 9 ) ) then white := '1'; end if;
	
	return white;

	end show_score;

begin


	Inst_clock25: entity work.clock25
	port map (
		CLKIN_IN => 			CLK,
		CLKDV_OUT => 			clk25,
		CLKIN_IBUFG_OUT => 	open,
		CLK0_OUT => 			open,
		LOCKED_OUT => 			open
	);


	generate_vsync : process ( clk25 )
		variable cnt : integer := 0;
	begin

		if rising_edge ( clk25 ) then
		
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
			
			VSYNC <= vs;

		end if;

	end process generate_vsync;


	generate_hsync : process ( clk25 )
	begin

		if rising_edge ( clk25 ) then
			
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

			HSYNC <= hs;

		end if;

	end process generate_hsync;

	
	generate_disp_en_h : process ( clk25 )
	begin
	
		if cnth < 144 or cnth > 784 then
			disp_en_h <= '0';
		else
			disp_en_h <= '1';
		end if;
	
	end process generate_disp_en_h;
	
	
	generate_disp_en_v : process ( clk25 )
	begin
	
		if cntv < 24_800 or cntv > 408_800 then
			disp_en_v <= '0';
		else
			disp_en_v <= '1';
		end if;
	
	end process generate_disp_en_v;


	paddle1 : process ( clk25 )
		variable presc : integer := 0;
	begin
	
		if rising_edge ( clk25 ) then
			if P1UP = '1' and pad1Top > 0 and presc > 200_000 then
				pad1Top <= pad1Top - 1;
				presc := 0;
			end if;

			if P1DOWN = '1' and pad1Top + pad1Len < 479 and presc > 200_000 then
				pad1Top <= pad1Top + 1;
				presc := 0;
			end if;
			
			if presc < 210_000 then
				presc := presc + 1;
			end if;
		end if;

	end process paddle1;
	
	
	paddle2 : process ( clk25 )
		variable presc : integer := 0;
	begin
	
		if rising_edge ( clk25 ) then
			if P2UP = '1' and pad2Top > 0 and presc > 200_000 then
				pad2Top <= pad2Top - 1;
				presc := 0;
			end if;

			if P2DOWN = '1' and pad2Top + pad2Len < 479 and presc > 200_000 then
				pad2Top <= pad2Top + 1;
				presc := 0;
			end if;
			
			if presc < 210_000 then
				presc := presc + 1;
			end if;
		end if;

	end process paddle2;
	
	
	ball : process ( clk25 )
		variable presc_x : integer := 0;
		variable presc_y : integer := 0;
		variable dir_x : bit := '1';
		variable dir_y : bit := '1';
		variable speed_y : integer := 15; -- Increasing it to 4 causes the ball to remain at x = start
		variable speed_x : integer := 100;
	begin
	
		if rising_edge ( clk25 ) then
			if presc_x < 50_000_000 then
				presc_x := presc_x + speed_x;
			else
				presc_x := 0;
				if dir_x = '1' then
					bx <= bx + 1;
					if bx = 550 and ( by + bsize > pad2Top and by < pad2Top + pad2Len ) then -- Bounce right, increase x speed, change y speed
						speed_x := speed_x + 15;
						dir_x := '0';
						if dir_y = '1' then
							speed_y := speed_y + (by + 10 - (pad2Top + 50)); -- dir_y may change u idiot ;/
							if speed_y < 0 then
								presc_x := 50_000_000;
								presc_y := 50_000_000;
								speed_y := -speed_y;
								dir_y := '0';
							end if;
						else
							speed_y := speed_y - (by + 10 - (pad2Top + 50));
							if speed_y < 0 then
								presc_x := 50_000_000;
								presc_y := 50_000_000;
								speed_y := -speed_y;
								dir_y := '1';
							end if;
						end if;
					end if;
					if bx > 670 then -- New game
						sc1 <= sc1 + 1;
						if sc1 > 9 then
							sc1 <= 0;
							sc2 <= 0;
						end if;
						bx <= 310;
						speed_x := 100;
						speed_y := 15;
					end if;
				else
					bx <= bx - 1;
					if bx = 70 and ( by + bsize > pad1Top and by < pad1Top + pad1Len ) then -- Bounce left, increase x speed, change y speed
						speed_x := speed_x + 15;
						dir_x := '1';
						if dir_y = '1' then
							speed_y := speed_y + (by + 10 - (pad1Top + 50)); -- dir_y may change u idiot ;/
							if speed_y < 0 then
								presc_x := 50_000_000;
								presc_y := 50_000_000;
								speed_y := -speed_y;
								dir_y := '0';
							end if;
						else
							speed_y := speed_y - (by + 10 - (pad1Top + 50));
							if speed_y < 0 then
								presc_x := 50_000_000;
								presc_y := 50_000_000;
								speed_y := -speed_y;
								dir_y := '1';
							end if;
						end if;
					end if;
					if bx < -50 then -- New game
						sc2 <= sc2 + 1;
						if sc2 > 9 then
							sc1 <= 0;
							sc2 <= 0;
						end if;
						bx <= 310;
						speed_x := 100;
						speed_y := 15;
					end if;
				end if;
			end if;
			
			if presc_y < 5_000_000 then
				presc_y := presc_y + speed_y;
			else
				presc_y := 0;
				if dir_y = '1' then
					by <= by + 1;
					if by > 460 then -- Bounce bottom
						dir_y := '0';
					end if;
				else
					by <= by - 1;
					if by < 0 then -- Bounce top
						dir_y := '1';
					end if;
				end if;
			end if;
		end if;
		
	end process ball;


	display : process ( clk25 )
	begin

		if rising_edge ( clk25 ) then
			if disp_en_h = '1' and disp_en_v = '1' then
				if ( px > 50 and px < 70 and py > pad1Top and py < pad1Top + pad1Len ) or 		-- Paddle 1
					( px > 570 and px < 590 and py > pad2Top and py < pad2Top + pad2Len ) or	-- Paddle 2
					( px > bx and px < bx + bsize and py > by and py < by + bsize ) or			-- Ball
					( show_score ( px, py, 100, 50, sc1 ) = '1' ) or									-- Score 1 (1 digit)
					( show_score ( px, py, 510, 50, sc2 ) = '1' ) then									-- Score 2 (1 digit)
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