-------------------------- CONTROL-PATH -----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity CtrlPath is
  	Port (
		LMode	: in std_logic := '0'; --Mode of operation
		LMRes	: in std_logic_vector(63 downto 0); --Result of multiply
	  	Lwb		: in std_logic; --Write Back
		Lmw		: in nibble; -- Write enable from PMconnect
		Lindex	: in DT_index; --Pre/Post Indexing
		Lsize	: in DT_size; --Size of Data Transfer
		Lsign	: in std_logic; --Signed/Unsigned Data Transfer
  		Lsrsrc	: in Shift_Rotate_src; --Source of shift-rotate value
  		LC		: in std_logic := '0'; --Carry flag
  		LAS		: in word := X"00000000"; --First ALU operand from FSM
        LBS		: in word := X"00000000"; --Second ALU operand from FSM
  		LState	: in integer := 1; --State of the FSM
	    Lchk	: in std_logic := '0'; --predicate from Condition Checker
	    Lic		: in instr_class_type;
	    Ldps	: in DP_operand_src_type;
	    Lop1	: in optype; --operand for ALU
        Lra		: in word := X"00000000"; --ALU output
    	Lins	: in word := X"00000000"; --Instruction
	    Ldout1	: in word := X"00000000"; --Register File output for first operand
	    Ldout2	: in word := X"00000000"; --Register File output for second operand
	    Los		: in DT_offset_sign_type;
	    Lldst	: in load_store_type;
        LDR		: in word := X"00000000"; --Data Memory Output
    	LRes	: in word := X"00000000";  --Memory write address
        Lpc		: in word := X"00000000";  --Memory write address
        LShift	: out byte := X"00"; --The shift-rotate ammount
        LPen	: out std_logic := '0'; --Write enable for pc
        LDrad	: out byte := X"00"; --Data Memory Address to be read
		Lrad1	: out nibble := X"0"; --First Register to be Read
		Lrad2	: out nibble := X"0"; --Second Register to be Read
        Lwrad	: out nibble := X"0"; --Register to be written
	    Len		: out std_logic := '0'; --write enable for Register File
	    Lwren	: out nibble := X"0"; --write enable for Data Memory
	    Lop		: out optype; --effective operand
	    La		: out word := X"00000000"; --First operand of ALU
	    Lb		: out word := X"00000000"; --Second operand of ALU
        LAa		: out word := X"00000000"; --First operand that goes to ALU
        LAb		: out word := X"00000000"; --Second operand that goes to ALU
        Ldtin	: out word := X"00000000"; --Data to be written in register
	    Lma		: out bit_pair := "00"; --MSB of ALU operands: 0 => op1, 1 => op2
		LAdr 	: out bit_pair := "00"; --Selector for which byte to transfer
		LNpc	: out word := X"00000000"; --New PC value
        Lcin	: out std_logic := '0' --ALU Carry
  	);
end CtrlPath;

architecture rtl of CtrlPath is
begin
  LShift <= std_logic_vector(resize(unsigned(Lins(11 downto 8)), 8)) when (Lic = DP and Ldps = imm) else
  			std_logic_vector(resize(unsigned(Lins(11 downto 7)), 8)) when ((Lic = DP and Ldps = reg) or (Lic = DT and Ldps = imm)) and (Lsrsrc = srim) else
            Ldout1(7 downto 0) when ((Lic = DP and Ldps = reg) or (Lic = DT and Ldps = imm)) and (Lsrsrc = srrg) else
            X"00";
  LPen	<=	'1' when (LState = 1 or (LState = 11 or LState = 12)) or (Lchk = '1' and LState = 5) else
  			'0';
  Lrad2 <= 	Lins(15 downto 12) when LState = 4 or (LState = 0 and Lic = MUL) else
			Lins(3 downto 0);
  Lrad1 <= 	"1110" when Lic = RT else
  			Lins(11 downto 8) when LState = 0 else
  			Lins(19 downto 16);
  LAdr	<=	Ldout1(1 downto 0);
  Lwrad <= 	"1110" when LState = 10 or (LState = 0 and (Lic = BRN and Lins(24) = '1')) else
  			Lins(19 downto 16) when (LState = 7 or LState = 8) or (LState = 3 and Lic = MUL) else
  			Lins(15 downto 12);
  Lb    <=	std_logic_vector(resize(signed(Lins(23 downto 0)), 32)) when (Lic = BRN and Lchk = '1') else
  			Ldout2 when (Lic = MUL or (Lic = DT and Ldps = imm)) or (Lic = DP and Ldps = reg) else
  			std_logic_vector(resize(unsigned(Lins(7 downto 0)), 32)) when (Lic = DP and Ldps = imm) else
			std_logic_vector(resize(unsigned(Lins(11 downto 0)), 32)) when (Lic = DT and Ldps = reg) and (Lsize = WordDT or (Lsize = ByteDT and Lsign = '0')) else
            std_logic_vector(resize(unsigned(Lins(11 downto 8) & Lins(3 downto 0)), 32)) when (Lic = DT and Ldps = reg) else
            X"FFFFFFFF";
  La	<=	Ldout1;
  LAb 	<= 	X"00000000" when LState = 1 else
  			LBS;
  LAa	<=	"00" & Lpc(31 downto 2) when LState = 1 or LState = 5 else
  			LAS;
  Lop 	<=  adc when (LState = 1) else
  			add when (Lic = DT and Los = plus) else
	       	sub when (Lic = DT and Los = minus) else
           	Lop1 when (Lic = Dp) else
           	adc;
  Lcin	<=	'1' when LState = 5 or LState = 1 else
  			LC;
  Lma 	<= 	LAS(31) & LBS(31);
  Lwren <= 	Lmw when LState = 7 else
            "0000";
  Len 	<= 	'1' when Lchk = '1' and ((LState = 10 or ((Lic = BRN and Lins(24) = '1') and LState = 0)) or ((Lic = MUL and (LState = 3 or (LState = 6 and Lins(23) = '1'))) or (LState = 9 or ((LState = 7 or LState = 8) and (Lindex = post or Lwb = '1')) or ((Lic = DP and LState = 6) and (((Lop1 /= cmp) and (Lop1 /= cmn)) and ((Lop1 /= tst) and (Lop1 /= teq))))))) else -- assuming only word write
		   	'0';
  Ldtin <= 	Lpc when LState = 10 or (Lic = BRN and (Lins (24) = '1' and LState = 0)) else
  			LMRes(31 downto 0) when Lic = MUL and ((LState = 3 and Lins(23) = '0') or (LState = 6 and Lins(23) = '1')) else
			LMRes(63 downto 32) when Lic = MUL and (LState = 3 and Lins(23) = '1') else
			LDR when LState = 9 else
            LRes when (Lic = DP and LState = 6) or (LState = 7 or LState = 8) else
            Ldout1;
  LDrad <=	Lpc(7 downto 0) when LState = 1 else
			LRes(7 downto 0) when Lindex = pre else
			LAS(7 downto 0);
  LNpc	<=	X"00000008" when LState = 11 else
			X"00000000" when LState = 12 else
  			Ldout1 when (LState = 5 and Lic = RT) else
  			Lra(29 downto 0) & "00";
end rtl;