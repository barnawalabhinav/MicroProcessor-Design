--------------------------- REGISTER-FILE ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MyTypes.all;

entity RegFile is
  Port (
  	Rrad1 	: in nibble := X"0"; --read address 1
  	Rrad2 	: in nibble := X"0"; --read address 2
  	Rwrad	: in nibble := X"0"; --write address
  	Rdtin 	: in word := X"00000000"; --data input
  	Ren	 	: in std_logic := '0'; --write enable
  	Rclk	: in std_logic := '0'; --clock
  	Rdout1 	: out word := X"00000000"; --data output 1
  	Rdout2 	: out word := X"00000000" --data output 2
    );
end RegFile;

architecture rtl of RegFile is
	type mem is array(0 to 15) of word; --array
    signal memory : mem := (others => (others => '0'));
begin
    Rdout1 <= memory(to_integer(unsigned(Rrad1))); --read from the register fle
    Rdout2 <= memory(to_integer(unsigned(Rrad2))); --read from the register fle
	process(Rclk)
    begin
    	if (Ren = '1') and rising_edge(Rclk) then --write in the register file
            memory(to_integer(unsigned(Rwrad))) <= Rdtin;
        end if;
    end process;
end rtl;