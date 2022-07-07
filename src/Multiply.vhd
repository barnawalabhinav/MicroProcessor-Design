---------------------------- MULTIPLY -------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity MUL is
  Port (
	MlFst	: in word := X"00000000"; --operand 1
  	MlSnd 	: in word := X"00000000"; --operand 2
	MlAdd	: in std_logic_vector(63 downto 0) := X"0000000000000000"; --Addend
	MlLng	: in std_logic := '0'; --Long Multiply (Bit 23)
  	MlSgn	: in std_logic := '0'; --Signed-Unsigned (Bit 22)
  	MlAcm 	: in std_logic := '0'; --Accumulate (Bit 21)
  	MlRes	: out std_logic_vector(63 downto 0) := X"0000000000000000" --Result
	);
end MUL;

architecture rtl of MUL is
	signal prod : signed (65 downto 0) := X"0000000000000000" & "00";
	signal x1, x2 : std_logic := '0';
begin
	x1	<=	MlFst(31) when MlLng = '1' and MlSgn = '1' else
			'0';
	x2	<=	MlSnd(31) when MlLng = '1' and MlSgn = '1' else
			'0';
	prod <= (signed(x1 & MlFst) * signed (x2 & MlSnd)) + signed(MlAdd) when MlAcm = '1' else
			signed(x1 & MlFst) * signed (x2 & MlSnd);
	MlRes <= std_logic_vector(prod(63 downto 0));
end rtl;
