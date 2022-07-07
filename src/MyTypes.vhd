library IEEE;
use IEEE.STD_LOGIC_1164.all;

package MyTypes is
	subtype word is std_logic_vector (31 downto 0);
	subtype hword is std_logic_vector (15 downto 0);
	subtype byte is std_logic_vector (7 downto 0);
	subtype nibble is std_logic_vector (3 downto 0);
	subtype bit_pair is std_logic_vector (1 downto 0);
	type optype is (andop, eor, sub, rsb, add, adc, sbc, rsc, tst, teq, cmp, cmn, orr, mov, bic, mvn);
	type instr_class_type is (DP, DT, MUL, BRN, RT, SWI);
	type DP_subclass_type is (arith, logic, comp, test, none);
	type DP_operand_src_type is (reg, imm);
	type load_store_type is (load, store);
	type DT_size is (Swap, WordDT, HalfDT, ByteDT);
	type DT_offset_sign_type is (plus, minus);
    type Condition_type is (eq, ne, cs, cc, mi, pl, vs, vc, hi, ls, ge, lt, gt, le, al, none);
    type Shift_Rotate_type is (LSL, LSR, ASR, RO);
    type Shift_Rotate_src is (srrg, srim);
	type DT_half_word_src is (himm, hreg);
	type DT_index is (pre, post);
	end MyTypes;
	package body MyTypes is
end MyTypes;