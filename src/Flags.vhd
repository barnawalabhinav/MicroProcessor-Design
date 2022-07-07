----------------------------- FLAGS --------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity Flags is
  Port (
	Frte	: in std_logic := '0'; --Check for RTE instruction
	Fchk	: in std_logic := '0'; --Condition check
	FMRes	: in std_logic_vector(63 downto 0); --Multilier Result
	FMlg	: in std_logic; --Multiply long or not
  	FState	: in integer := 1; --State of the FSM
  	Fclk	: in std_logic := '0'; --Clock signal
	Fic		: in instr_class_type;
    Fdpc	: in DP_subclass_type;
    Fop	: in optype;
    FS	: in std_logic := '0'; --S bit
    Fsr	: in std_logic := '0'; --Whether Shift/Rotate is provided
    Fcs	: in std_logic := '0'; --Carry out from Shifter
    Fca	: in std_logic := '0'; --Carry out from ALU
    Fra	: in word := X"00000000"; --Result output from ALU
    Fma	: in bit_pair := "00";  --MSB of ALU operands index 0 for op1 and index 1 for op2
	FM	: out std_logic := '0'; --Mode flag
    FC	: out std_logic := '0'; --Carry flag
    FN	: out std_logic := '0'; --Negtive flag
    FV	: out std_logic := '0'; --Overflow flag
    FZ	: out std_logic := '0'  --Zero flag
    );
end Flags;

architecture rtl of Flags is
begin
	process(Fclk)
    begin
   		if rising_edge(Fclk)  and (FState /= 1 and Fchk = '1') then
		   	if FState = 11 or FState = 12 then
				FM <= '1';
			elsif Fic = RT and Frte = '1' then
				FM <= '0';
			end if;
			if Fic = DP then
       			case Fdpc is
	            	when arith => if (FS = '1') then
                    	FC <= Fca; --carry
                    	FN <= Fra(31); --negative
                    	if (Fra = X"00000000") then FZ <= '1'; else FZ <= '0'; end if; --zero
                		case Fop is
	                    	when add | adc => FV <= ((Fma(0) and Fma(1)) and not Fra(31)) or ((not Fma(0) and not Fma(1)) and Fra(31)); --V = mA.mB.mS'+ mA'.mB'.mS
                        	when sub | sbc => FV <= ((Fma(0) and not Fma(1)) and not Fra(31)) or ((not Fma(0) and Fma(1)) and Fra(31)); --V = mA.mB'.mS'+ mA'.mB.mS
                       		when rsb | rsc => FV <= ((not Fma(0) and Fma(1)) and not Fra(31)) or ((Fma(0) and not Fma(1)) and Fra(31)); --V = mA'.mB.mS'+ mA.mB'.mS
                        	when others => null;
                    	end case;
                		end if;
                	when logic => if (FS = '1') then
	                	if (Fsr = '1') then FC <= Fcs; end if; --carry
                		FN <= Fra(31); --negative
                    	if (Fra = X"00000000") then FZ <= '1'; else FZ <= '0'; end if; --zero
                    	end if;
                	when comp => 
	                	FC <= Fca; --carry
                    	FN <= Fra(31); --negative
                    	if (Fra = X"00000000") then FZ <= '1'; else FZ <= '0'; end if; --zero
                    	case Fop is
	                    	when cmn => FV <= ((Fma(0) and Fma(1)) and not Fra(31)) or ((not Fma(0) and not Fma(1)) and Fra(31)); --V = mA.mB.mS'+ mA'.mB'.mS
                        	when cmp => FV <= ((Fma(0) and not Fma(1)) and not Fra(31)) or ((not Fma(0) and Fma(1)) and Fra(31)); --V = mA.mB'.mS'+ mA'.mB.mS
                        	when others => null;
                    	end case;
                	when test => if (Fsr = '1') then FC <= Fcs; end if; --carry
	                	FN <= Fra(31); --negative
                    	if (Fra = X"00000000") then FZ <= '1'; else FZ <= '0'; end if; --zero
                	when others => null;
            	end case;
			elsif Fic = MUL and FS = '1' then
				if FMRes = X"0000000000000000" then FZ <= '1'; else FZ <= '0'; end if;
				if FMlg = '1' then FN <= FMRes(63); else FN <= FMRes(31); end if;
			end if;
        end if;
    end process;
end rtl;
