----------------------------- CONDITION -----------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity Cond is
  Port (
	C_C		: in std_logic := '0'; --Carry flag
    CN		: in std_logic := '0'; --Negtive flag
    CV		: in std_logic := '0'; --Overflow flag
    CZ		: in std_logic := '0'; --Zero flag
	Ccd		: in Condition_type;	--Condition field
    Cchk	: out std_logic := '0' --Whether cd field is true or not
    );
end Cond;

architecture rtl of Cond is
begin
	with Ccd select
    	Cchk <= CZ when eq, --equal
        		(not CZ) when ne, --not equal
        		C_C when cs, --carry set
        		(not C_C) when cc, --carry clear
        		CN when mi, --minus
        		(not CN) when pl, --plus
        		CV when vs, --overflow set
        		(not CV) when vc, --overflow clear
        		C_C and (not CZ) when hi, --unsigned high
        		((not C_C) or CZ) when ls, --unsigned low
        		(not (CN xor CV)) when ge, --signed >=
        		(CN xor CV) when lt, --signed <
        		((not CZ) and (not (CN xor CV))) when gt, --signed >
        		(CZ or (CN xor CV)) when le, --signed <=
        		'1' when al, --always
                '0' when others; --erraneous
end rtl;