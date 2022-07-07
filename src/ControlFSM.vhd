---------------------------- CONTROL-FSM ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity FSM is
  Port (
	Schk	: in std_logic := '0'; --Condition check
  	Srst 	: in std_logic := '0'; --Reset signal
  	Sclk	: in std_logic := '0'; --Clock
    SDtout	: in word := X"00000000"; --Data Output from Memory
    LSA		: in word := X"00000000"; --Input for first operand
    LSB		: in word := X"00000000"; --Input for second operand
    Sic		: in instr_class_type;
    Sldst	: in load_store_type;
    SAra	: in word := X"00000000"; --ALU output
    SState	: inout integer := 1; --State of FSM
    SLshift	: in byte := X"00"; --The shift-rotate ammount from Control path
	SRad2	: in word := X"00000000"; --Output from second register
    SRshift	: out byte := X"00"; --The shift-rotate ammount
    SA		: out word := X"00000000"; --Register A
    SB		: out word := X"00000000"; --Register B
    SIR		: out word := X"00000000"; --Instruction
    SDR		: out word := X"00000000"; --Data to be written in Register
    SRes	: out word := X"00000000"; --Memory write address
	SDMem	: out word := X"00000000"; --Data To be written in memory
	SM1		: out word := X"00000000"; --Multiply first operand
	SM2		: out word := X"00000000"; --Multiply second operand
	SMadl	: out word := X"00000000"; --Lower half of Multiply Addend
	SMadh	: out word := X"00000000"; --Upper half of Multiply Addend
    SS		: out std_logic := '0' --set bit
  );
end FSM;  

architecture rtl of FSM is
begin
	process (Sclk)
    begin
      	if rising_edge(Sclk) then
        	case SState is
            	when 1 =>
                	SS <= '0';
            		SIR <= SDtout;
                    SState <= 2;
                when 2 =>
                	SS <= '0';
		-- Introducing Full Predication
					if (Schk = '1') then
						if Srst = '1' then SState <= 12;	
						elsif Sic = SWI then SState <= 10;
						else
							SA <= LSA;
							SM1 <= LSB;
							SMadh <= LSA;
							SState <= 0;
						end if;
					else SState <= 1;
					end if;
				when 10 =>
					SState <= 11;
				when 11 =>
					SState <= 1;
				when 12 =>
					SState <= 1;
                when 0 =>
                	SS <= '0';
                    SB <= LSB;
                    SRshift <= SLshift;
					SM2 <= LSA;
					SMadl <= LSB;
                  	if (Sic = DP or Sic = MUL) then SState <= 3;
                    elsif (Sic = DT) then SState <= 4;
                    elsif (Sic = BRN or Sic = RT) then SState <= 5;
                    end if;
                when 3 =>
                	SRes <= SAra;
                    if (Sldst = load) then SS <= '1'; else SS <= '0'; end if;
                    SState <= 6;
                when 4 =>
                	SS <= '0';
                	SRes <= SAra;
					SDMem <= SRad2;
                    if (Sldst = store) then SState <= 7;
                    else SState <= 8;
                    end if;
                when 5 =>
                	SS <= '0';
                    SState <= 1;
                when 6 =>
                	SS <= '0';
                    SState <= 1;
				when 7 =>
                	SS <= '0';
                	SState <= 1;
                when 8 =>
                	SS <= '0';
                	SDR <= SDtout;
                	SState <= 9;
                when 9 =>
                	SS <= '0';
                	SState <= 1;
                when others =>
                	null;
            end case;
        end if;
    end process;
end rtl;