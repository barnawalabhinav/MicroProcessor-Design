---------------------- ARITHEMATIC-LOGIC-UNIT ----------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity ALU is
  Port (
	Aa 	: in word := X"00000000"; --operand 1
  	Ab 	: in word := X"00000000"; --operand 2
  	Aop	: in optype; --opcode
  	Acin : in std_logic := '0'; --Carry in
  	Aca	: out std_logic := '0'; --Carry out
  	Ara	: out word := X"00000000" --result
	);
end ALU;

architecture rtl of ALU is
begin
  process(Aa, Ab, Aop, Acin) is
    variable total	: signed(32 downto 0);
	variable temp	: signed(31 downto 0);
    variable asn	: signed(31 downto 0);
    variable bsn	: signed(31 downto 0);
  begin
    asn := signed(Aa);
    bsn := signed(Ab);
    case Aop is
    	when andop => Ara <= Aa and Ab; Aca <= Acin; --and: Logical AND
        when eor => Ara <= Aa xor Ab; Aca <= Acin; --eor: Logical XOR
        when sub => --sub: Subtraction
        	total := ('0' & asn) + not('1' & bsn) + 1;
            Ara <= std_logic_vector(total(31 downto 0));
           	temp := ('0' & asn(30 downto 0)) + not('1' & bsn(30 downto 0)) + 1;
            Aca <= total(32);
        when rsb => --rsb: Reverse Subtraction
        	total := ('0' & bsn) + not('1' & asn) + 1;
            Ara <= std_logic_vector(total(31 downto 0));
            temp := ('0' & bsn(30 downto 0)) + not('1' & asn(30 downto 0)) + 1;
            Aca <= total(32);
        when add => --add: Addition
        	total := ('0' & asn) + ('0' & bsn);
            Ara <= std_logic_vector(total(31 downto 0));
            temp := ('0' & asn(30 downto 0)) + ('0' & bsn(30 downto 0));
            Aca <= total(32);
        when adc => --adc: Addition with carry
        	total := ('0' & asn) + ('0' & bsn) + ("0000000000000000000000000000000" & Acin);
            Ara <= std_logic_vector(total(31 downto 0));
            temp := ('0' & asn(30 downto 0)) + ('0' & bsn(30 downto 0)) + ("0000000000000000000000000000000" & Acin);
            Aca <= total(32);
        when sbc => --sbc: Subtraction with carry
        	total := ('0' & asn) + not('1' & bsn) + ("0000000000000000000000000000000" & Acin);
            Ara <= std_logic_vector(total(31 downto 0));
            temp := ('0' & asn(30 downto 0)) + not('1' & bsn(30 downto 0)) + ("0000000000000000000000000000000" & Acin);
            Aca <= total(32);
        when rsc => --rsc: Reverse subtraction with carry
        	total := not('1' & asn) + ('0' & bsn) + ("0000000000000000000000000000000" & Acin);
            Ara <= std_logic_vector(total(31 downto 0));
            temp := not('1' & asn(30 downto 0)) + ('0' & bsn(30 downto 0)) + ("0000000000000000000000000000000" & Acin);
            Aca <= total(32);
        when tst => Ara <= Aa and Ab; Aca <= Acin; --tst: Same as AND but result is not written
        when teq => Ara <= Aa xor Ab; Aca <= Acin; --teq: Same as XOR but result is not writted
        when cmp => --cmp: Same as Subtraction but result is not written
        	total := ('0' & asn) + not('1' & bsn) + 1;
            Ara <= std_logic_vector(total(31 downto 0));
			temp := ('0' & asn(30 downto 0)) + not('1' & bsn(30 downto 0)) + 1;
            Aca <= total(32);
        when cmn => --cmn: Same as Addition but result is not written
        	total := ('0' & asn) + ('0' & bsn);
            Ara <= std_logic_vector(total(31 downto 0));
			temp := ('0' & asn(30 downto 0)) + ('0' & bsn(30 downto 0));
            Aca <= total(32);
        when orr => Ara <= Aa or Ab; Aca <= Acin; --orr: Logical OR
        when mov => Ara <= Ab; Aca <= Acin; --mov: Operand 2 (operand 1 is ignored)
        when bic => Ara <= Aa and not(Ab); Aca <= Acin; --bic: Bit clear
    	when mvn => Ara <= not(Ab); Aca <= Acin; --mvn: NOT operand 2 (operand 1 ignored)
        when others => null;
    end case;
  end process;
end rtl;
