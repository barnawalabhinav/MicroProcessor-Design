------------------------------ MEMORY -------------------------------

--Memory Partition :
--	Address 0 to 15 => Priviledged Memory
--	Address 16 to 63 => Instruction Memory
-- 	Address 64 to 127 => User Memory

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.MyTypes.all;

entity Mem is
  Port (
	Mstate	: in integer; --state of the FSM
	Mmod	: in std_logic; --mode flag
	Minp	: in std_logic_vector(8 downto 0); --input port
  	Mclk	: in std_logic := '0'; --clock
  	Madr 	: in byte := X"00"; --address
  	Mdtin	: in word := X"00000000"; --data to be written
  	Mwren	: in nibble := X"0"; --4 bit write enable
  	Mdtout 	: out word := X"00000000" --data output
    );
end Mem;

architecture rtl of Mem is
	type mem is array(0 to 127) of word; --array
	---- Input Sequence 1 for Multiply -----
	signal memory : mem := ( 0 => X"EA000002", --branch to 4 for reset ISR
							 2 => X"EA000003", --branch to 7 for SWI ISR
	-- (*ISR RESET BEGINS*) ------------------
							 4 => X"E3A0E040", --	mov r14, <user address>
							 5 => X"EA000001", --	b R
	-- (*ISR SWI BEGINS*) --------------------
							 7 => X"E5900000", --L: ldr r0, [r0]
	-- (*ISE RTE BEGINS*) --------------------
							 8 => X"E6000011", --R:	rte
	-- (*USER PROGRAM BEGINS*) ---------------
    
    ------- Put your test cases here -------
    
					---- Sample Input sequence 1 ----
--							16 => X"E3A00001",
--							17 => X"13A01004",
--							18 => X"EB000001",
--							19 => X"E5312004",
--							20 => X"EA000001",
--							21 => X"E4810004",
--							22 => X"E6000010",
					---- Sample Input sequence 2 ----
							16 => X"E3A0003C",
							17 => X"EF000000",
							18 => X"E1A00460",
							19 => X"E1B000A0",
							20 => X"3AFFFFFA",
							21 => X"E1A00BE0",
							22 => X"E0801000",
							23 => X"E3A0003C",
							24 => X"EF000000",
							25 => X"E1A01000",
					---- Sample Input sequence 3 ----
--							16 => X"E3A00001",
--							17 => X"13A01002",
--							18 => X"EB000003",
--							19 => X"E2400035",
--							20 => X"E5800000",
--							21 => X"E3A03003",
--							22 => X"EA000009",
--							23 => X"03A04004",
--							24 => X"E1A0400E",
--							25 => X"E3A0003C",
--							26 => X"EF000000",
--							27 => X"E1A00460",
--							28 => X"E1B000A0",
--							29 => X"3AFFFFFA",
--							30 => X"E1A00BE0",
--							31 => X"E1A0E004",
--							32 => X"E6000010",
--							33 => X"E1A01000",
					   others => X"00000000"
						);
	----------------------------------------
begin
	Mdtout <= memory(to_integer(unsigned(Madr(7 downto 2))) + 64) when Mmod = '0' and Mstate /= 1 else --users memory starts from 64
			X"00000" & "000" & Minp when Madr = X"3C" and Mmod = '1' else --priviledged mode read
			memory(to_integer(unsigned(Madr(7 downto 2)))); --priviledged memory starts from 0
    process(Mclk)
    begin
    	if rising_edge(Mclk) then
        	if (Mwren(0) = '1') then --write in the least significant byte
            	memory(to_integer(unsigned(Madr(7 downto 2))) + 64)(7 downto 0) <= Mdtin(7 downto 0);
            end if;
        	if (Mwren(1) = '1') then --write in the second least significant byte
            	memory(to_integer(unsigned(Madr(7 downto 2))) + 64)(15 downto 8) <= Mdtin(15 downto 8);
            end if;
        	if (Mwren(2) = '1') then --write in the third least significant byte
            	memory(to_integer(unsigned(Madr(7 downto 2))) + 64)(23 downto 16) <= Mdtin(23 downto 16);
            end if;
        	if (Mwren(3) = '1') then --write in the most significant byte
            	memory(to_integer(unsigned(Madr(7 downto 2))) + 64)(31 downto 24) <= Mdtin(31 downto 24);
            end if;
        end if;
    end process;
end rtl;