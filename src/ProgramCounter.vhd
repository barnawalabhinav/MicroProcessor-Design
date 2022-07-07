-------------------------- PROGRAM-COUNTER ---------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity ProgCount is
  Port (
  	Pclk : in std_logic := '0'; --clock signal
  	Pen	 : in std_logic := '0'; --write enable
    Prst : in std_logic := '0'; --reset
    Pbr	 : in word := X"00000040"; --next instruction logic
  	pc	 : out word := X"00000040" --program counter
    );
end ProgCount;

architecture rtl of ProgCount is
begin
	process(Pclk)
    begin
    	if Prst = '1' then pc <= X"00000000";
    	elsif rising_edge(Pclk) and Pen = '1' then pc <= Pbr;
    	end if;
    end process;
end rtl;
