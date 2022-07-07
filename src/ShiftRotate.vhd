--------------------------- SHIFT-ROTATE ----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity ShiftRor is
  Port (
  	SRdps	: in DP_operand_src_type; --How is second operand provided
  	SRsrs	: in Shift_Rotate_src; --Source of shift-rotate value
  	SRCin	: in std_logic := '0'; --Shift Carry in
    SRic	: in instr_class_type; --type of instruction
    SRtype	: in Shift_Rotate_type; --type of shift-rotate
    SRinp	: in word := X"00000000"; --Value to be shifted
    StRot	: in byte := X"00"; --Shift-Rotate value to be incorporated
    SRout	: out word := X"00000000"; --Shifted output
    SRCout	: out std_logic := '0' --Shift Carry out
  );
end ShiftRor;

architecture rtl of ShiftRor is
	signal sr1, sr2, sr3, sr4, sr5 : word := X"00000000"; --intermedate shifted/rotated values
    signal c1, c2, c3, c4, c5 : std_logic := '0'; --intermediate carry
    signal big : std_logic := '0'; --To check if StRot >= 32
begin

  -- Initial Check ---
  
	big <= (StRot(7) or StRot(6)) or (StRot(5) or StRot(4));

  --- Stage 1 ---
  
	sr1 <= '0' & SRinp(31 downto 1) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and SRtype = LSR) else
    	SRinp(31) & SRinp(31 downto 1) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and SRtype = ASR) else
        SRinp(0) & SRinp(31 downto 1) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and SRtype = RO) else
        SRinp(30 downto 0) & '0' when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and SRtype = LSL) else
        SRinp;
        
	c1 <= SRinp(0) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and ((SRtype = LSR or SRtype = ASR) or SRtype = RO)) else
        SRinp(31) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(0) = '1' and SRtype = LSL) else
        SRCin;
  
  --- Stage 2 ---
        
    sr2 <= "00" & sr1(31 downto 2) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and SRtype = LSR) else
    	SRinp(31) & SRinp(31) & sr1(31 downto 2) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and SRtype = ASR) else
        sr1(1) & sr1(0) & sr1(31 downto 2) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and SRtype = RO) else
        sr1(29 downto 0) & "00" when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and SRtype = LSL) else
        sr1(1) & sr1(0) & sr1(31 downto 2) when (SRic = DP and SRdps = imm) and StRot(0) = '1' else
        sr1;
        
	c2 <= sr1(1) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and ((SRtype = LSR or SRtype = ASR) or SRtype = RO)) else
        sr1(30) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(1) = '1' and SRtype = LSL) else
        c1;
  
  --- Stage 3 ---
        
    sr3 <= "0000" & sr2(31 downto 4) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and SRtype = LSR) else
    	SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & sr2(31 downto 4) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and SRtype = ASR) else
        sr2(3) & sr2(2) & sr2(1) & sr2(0) & sr2(31 downto 4) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and SRtype = RO) else
        sr2(27 downto 0) & "0000" when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and SRtype = LSL) else
        sr2(3) & sr2(2) & sr2(1) & sr2(0) & sr2(31 downto 4) when (SRic = DP and SRdps = imm) and StRot(1) = '1' else
        sr2;
        
	c3 <= sr2(3) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and ((SRtype = LSR or SRtype = ASR) or SRtype = RO)) else
        sr2(28) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(2) = '1' and SRtype = LSL) else
        c2;
  
  --- Stage 4 ---
        
    sr4 <= X"00" & sr3(31 downto 8) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and SRtype = LSR) else
    	SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & sr3(31 downto 8) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and SRtype = ASR) else
        sr3(7) & sr3(6) & sr3(5) & sr3(4) & sr3(3) & sr3(2) & sr3(1) & sr3(0) & sr3(31 downto 8) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and SRtype = RO) else
        sr3(23 downto 0) & X"00" when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and SRtype = LSL) else
        sr3(7) & sr3(6) & sr3(5) & sr3(4) & sr3(3) & sr3(2) & sr3(1) & sr3(0) & sr3(31 downto 8) when (SRic = DP and SRdps = imm) and StRot(2) = '1' else
        sr3;
        
	c4 <= sr3(7) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and ((SRtype = LSR or SRtype = ASR) or SRtype = RO)) else
        sr3(24) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(3) = '1' and SRtype = LSL) else
        c3;
  
  --- Stage 5 ---
        
    sr5 <= X"0000" & sr4(31 downto 16) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and SRtype = LSR) else
    	SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & SRinp(31) & sr4(31 downto 16) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and SRtype = ASR) else
        sr4(15) & sr4(14) & sr4(13) & sr4(12) & sr4(11) & sr4(10) & sr4(9) & sr4(8) & sr4(7) & sr4(6) & sr4(5) & sr4(4) & sr4(3) & sr4(2) & sr4(1) & sr4(0) & sr4(31 downto 16) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and SRtype = RO) else
        sr4(15 downto 0) & X"0000" when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and SRtype = LSL) else
        sr4(15) & sr4(14) & sr4(13) & sr4(12) & sr4(11) & sr4(10) & sr4(9) & sr4(8) & sr4(7) & sr4(6) & sr4(5) & sr4(4) & sr4(3) & sr4(2) & sr4(1) & sr4(0) & sr4(31 downto 16) when (SRic = DP and SRdps = imm) and StRot(3) = '1' else
        sr4;
         
	c5 <= sr4(15) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and ((SRtype = LSR or SRtype = ASR) or SRtype = RO)) else
        sr4(16) when ((SRic = DP and SRdps = reg) or ((SRic = DT and SRsrs = srim) and SRdps = imm)) and (StRot(4) = '1' and SRtype = LSL) else
        c4;

  --- Final Stage ---
  
  	SRout <= X"00000000" when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = LSR) and big = '1') else
    	X"00000000" when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = ASR) and (big = '1' and SRinp(31) = '0')) else
    	X"FFFFFFFF" when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = ASR) and (big = '1' and SRinp(31) = '1')) else
    	SRinp when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = RO) and StRot = X"20") else
    	X"00000000" when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = LSL) and big = '1') else
    	sr5;
        
	SRCout <= SRinp(31) when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and (SRtype = LSR or SRtype = RO)) and StRot = X"20") else
    	SRinp(0) when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = LSL) and StRot = X"20") else
        '0' when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and (SRtype = LSR or SRtype = LSL)) and big = '1') else
    	SRinp(31) when (SRic = DP and SRdps = reg) and ((SRsrs = srrg and SRtype = ASR) and big = '1') else
    	c5;
end rtl;