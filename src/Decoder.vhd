------------------------------ DECODER ------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity Decoder is
 Port (
	Dins	: in word := X"00000000"; --instruction
	Dic 	: out instr_class_type; --instruction class
	Dop 	: out optype; --operation
	Ddpc 	: out DP_subclass_type; --DP subclass
	Ddps 	: out DP_operand_src_type; --DP operand source
	Dldst	: out load_store_type; --load/store
	Dos 	: out DT_offset_sign_type; --DT offset sign
    Dcd 	: out Condition_type; --Condition
    Dsr		: out Shift_Rotate_type; --Type of Shift or Rotate
    Dsrs 	: out Shift_Rotate_src; --How is shift-rotate provided
	Dsign	: out std_logic; --Sign of extension of DT instructions
	Dsize 	: out DT_size; --Type of Data Transfer
	Didx 	: out DT_index; --Pre/Post indexing
	Dwb		: out std_logic; --Write Back
	Dhsrc 	: out DT_half_word_src --Offset Src for Half Word Transfer
	);
end Decoder;

architecture Behavioral of Decoder is
	type oparraytype is array (0 to 15) of optype;
	type condarraytype is array (0 to 15) of Condition_type;
    type srarraytype is array (0 to 3) of Shift_Rotate_type;
	constant oparray : oparraytype := (andop, eor, sub, rsb, add, adc, sbc, rsc, tst, teq, cmp, cmn, orr, mov, bic, mvn);
    constant condarray : condarraytype := (eq, ne, cs, cc, mi, pl, vs, vc, hi, ls, ge, lt, gt, le, al, none);
    constant srarray : srarraytype := (LSL, LSR, ASR, RO);
	signal TmpIc : instr_class_type;
	begin
        Dcd <= condarray (to_integer(unsigned (Dins(31 downto 28))));
		with Dins (27 downto 26) select
			TmpIc <= DP when "00",
				DT when "01",
				BRN when "10",
				SWI when others;
		Dic <=	RT when Dins(27 downto 25) = "011" and Dins(4) = '1' else
				MUL when Dins(27 downto 24) = X"0" and Dins(7 downto 4) = X"9" else
				DT when Dins(27 downto 25) = "000" and (Dins(7) = '1' and Dins(4) = '1') else
        		TmpIc;
		Dop <= oparray (to_integer(unsigned (Dins(24 downto 21))));
		with Dins (24 downto 22) select
			Ddpc <= arith when "001" | "010" | "011",
				logic when "000" | "110" | "111",
				comp when "101",
				test when others;
		Ddps <= reg when Dins (25) = '0' else imm;
		Dldst <= load when Dins (20) = '1' else store;
		Dos <= plus when Dins (23) = '1' else minus;
        Dsr <= srarray (to_integer(unsigned (Dins(6 downto 5))));
        Dsrs <= srrg when Dins (4) = '1' else srim;
		Dsize <= ByteDT when (Dins(27 downto 26) = "01" and Dins(22) = '1') or (Dins(27 downto 25) = "000" and Dins(6 downto 5) = "10") else
				Swap when Dins(27 downto 25) = "000" and Dins(6 downto 5) = "00" else
				HalfDT when Dins(27 downto 25) = "000" else
				WordDT;
		Dsign <= Dins(6) when Dins(27 downto 25) = "000" else
				'0';
		Dhsrc <= himm when Dins(22) = '1' else hreg;
		Didx <= pre when Dins(24) = '1' else post;
		Dwb <= Dins(21);
end Behavioral;