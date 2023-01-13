library IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

---- input output declaration:---------------------------------------------------------------------------------------------------
entity vars is
    Port(
		-- in
    	clk, reset, stop_process, count_up, count_down: in std_logic;
		-- out
		RS : out std_logic:='1';
		RW : out std_logic:='0';
		EN : out std_logic:='1';
		number : out std_logic_vector (7 downto 0) := "00000000"
	);
end vars;
---------------------------------------------------------------------------------------------------------------------------------

architecture LCD_COUNTER of vars is
---- signals declaration:--------------------------------------------------------------------------------------------------------
--> counter
signal counter_clk : std_logic := '0';
signal add_10 : std_logic := '0';
signal nbr_units : std_logic_vector (7 downto 0) := "00110000" ; 
signal nbr_tens : std_logic_vector (7 downto 0) := "00110000" ; 
signal tmp_clk : std_logic_vector (27 downto 0) := (others => '0') ; 
---------------------------------------------------------------------------------------------------------------------------------
--> lcd
signal lcd_clk : std_logic := '0';
signal tmp_lcd_clk : std_logic_vector (15 downto 0) := (others => '0') ; 
---------------------------------------------------------------------------------------------------------------------------------

begin
---- Counter clock divider	--> 1 second clock-----------------------------------------------------------------------------------
counter_clk_divider : process(clk, tmp_clk, counter_clk)  
begin
	if rising_edge(clk) then
		if tmp_clk < 50000000 then
		-- 50MHZ for a rising edge of clk
			tmp_clk <= tmp_clk + 1;
			counter_clk <= '0';
		else
			tmp_clk <= (others => '0');
			counter_clk <= '1';
		end if;
	end if;
end process;
---------------------------------------------------------------------------------------------------------------------------------

----counting---------------------------------------------------------------------------------------------------------------------
units_counting : process(reset, stop_process, counter_clk, nbr_units, count_up, count_down) 
begin 
	if reset = '1' then 
		nbr_units <= "00110000";
		nbr_tens <= "00110000";
	elsif stop_process /= '1' and rising_edge(counter_clk) then
		if count_up = '1' and count_down = '0' then
			if nbr_units < 57 then
				nbr_units <= nbr_units + 1;
			else
				nbr_units <= "00110000";
				add_10 <= '1';
			end if;
		elsif count_up = '0' and count_down = '1' then
			if nbr_units > 48 then
				nbr_units <= nbr_units - 1;
			else 
				nbr_units <= "00111001";
				add_10 <= '1';
			end if;
		end if;
	end if;
end process;

tens_counting : process(reset, stop_process, add_10, nbr_tens, count_up, count_down) 
begin 
	if stop_process /= '1' and rising_edge(add_10) then
		if count_up = '1' and count_down = '0' then
			if nbr_tens < 57 then 
				nbr_tens <= nbr_tens + 1;
			else 
				nbr_tens <= "00110000";
			end if;
		elsif count_up = '0' and count_down = '1' then
			if nbr_tens > 48 then 
				nbr_tens <= nbr_tens - 1; 
			else 
				nbr_tens <= "00111001";
			end if;
		end if;
		add_10 <= '0';
	end if;
end process;
----end counting-----------------------------------------------------------------------------------------------------------------

----- LCD clock divider		--> 1.3ms divider
lcd_clk_divider_process : process (clk, tmp_lcd_clk) 
begin
	if rising_edge(clk) then
		tmp_lcd_clk <= tmp_lcd_clk + 1;
	end if;
	lcd_clk <= tmp_lcd_clk(15);
end process;
-----------------------------------------------------------------------------------------------------------


---------------------------------------------------------------------------------------------------------------------------------

end LCD_COUNTER ;

