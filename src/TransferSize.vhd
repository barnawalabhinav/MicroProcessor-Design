----------------- WORD/HALF-WORD/BYTE DATA TRANSFER -----------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;

entity PMconnect is
  Port (
	DTRout	: in word; --Source Data for Store
	DTMout 	: in word; --Data Output from Memory for Load
	DTins 	: in load_store_type;
	DTSize	: in DT_size; --Data transfer size
	DTsign	: in std_logic; --Signed/Unsigned transfer
	DTAdr 	: in bit_pair; --Address for the memory
	DState	: in integer; --State of the FSM
	DTRin 	: out word; --Data to be put in register
	DTMin 	: out word; --Data input of memory
	DTMW 	: out nibble --Memory Write enable
    );
end PMconnect;

architecture rtl of PMconnect is
begin
	DTMW <= "0011" when DTins = store and (DTSize = HalfDT and DTAdr = "00") else
			"1100" when DTins = store and (DTSize = HalfDT and DTAdr = "10") else
			"0001" when DTins = store and (DTSize = ByteDT and DTAdr = "00") else
			"0010" when DTins = store and (DTSize = ByteDT and DTAdr = "01") else
			"0100" when DTins = store and (DTSize = ByteDT and DTAdr = "10") else
			"1000" when DTins = store and (DTSize = ByteDT and DTAdr = "11") else
			"1111" when DTins = store and DTSize = WordDT else
			"0000";
	DTMin(31 downto 24) <= 	DTRout(31 downto 24) when (DTins = store and DTSize = WordDT) else
							DTRout(15 downto 8) when (DTins = store and DTSize = HalfDT) else
							DTRout(7 downto 0) when (DTins = store and DTSize = ByteDT) else
							X"00";
	DTMin(23 downto 16) <= 	DTRout(23 downto 16) when DTins = store and DTSize = WordDT else
							DTRout(7 downto 0) when DTins = store and (DTSize = HalfDT or DTSize = ByteDT) else
							X"00";
	DTMin(15 downto 8) 	<= 	DTRout(15 downto 8) when DTins = store and (DTSize = WordDT or DTSize = HalfDT) else
							DTRout(7 downto 0) when DTins = store and DTSize = ByteDT else
							X"00";
	DTMin(7 downto 0) 	<= 	DTRout(7 downto 0) when DTins = store else
							X"00";
	DTRin(31 downto 24) <= 	DTMout(31 downto 24) when DState = 1 or (DTins = load and DTSize = WordDT) else
							DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) when (DTins = load and DTsign = '1') and ((DTSize = HalfDT and DTAdr = "00") or (DTSize = ByteDT and DTAdr = "01")) else
							DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) when (DTins = load and DTsign = '1') and ((DTSize = HalfDT and DTAdr = "10") or (DTSize = ByteDT and DTAdr = "11")) else
							DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "00") else
							DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "10") else
							X"00";
	DTRin(23 downto 16) <= 	DTMout(23 downto 16) when DState = 1 or (DTins = load and DTSize = WordDT) else
							DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) when (DTins = load and DTsign = '1') and ((DTSize = HalfDT and DTAdr = "00") or (DTSize = ByteDT and DTAdr = "01")) else
							DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) when (DTins = load and DTsign = '1') and ((DTSize = HalfDT and DTAdr = "10") or (DTSize = ByteDT and DTAdr = "11")) else
							DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "00") else
							DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "10") else
							X"00";
	DTRin(15 downto 8) <= 	DTMout(15 downto 8) when DState = 1 or (DTins = load and (DTSize = WordDT or (DTSize = HalfDT and DTAdr = "00"))) else
							DTMout(31 downto 24) when (DTins = load and DTAdr = "10") and DTSize = HalfDT else
							DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) & DTMout(7) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "00") else
							DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) & DTMout(15) when (DTins = load and DTsign = '1') and (DTSize = ByteDT and DTAdr = "01") else
							DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) & DTMout(23) when (DTins = load and DTSize = ByteDT) and (DTsign = '1' and DTAdr = "10") else
							DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) & DTMout(31) when (DTins = load and DTsign = '1') and (DTSize = ByteDT and DTAdr = "11") else
							X"00";
	DTRin(7 downto 0) <= 	DTMout(7 downto 0) when DState = 1 or (DTins = load and DTAdr = "00") else
							DTMout(15 downto 8) when DTins = load and DTAdr = "01" else
							DTMout(23 downto 16) when DTins = load and DTAdr = "10" else
							DTMout(31 downto 24) when DTins = load and DTAdr = "11" else
							X"00";
end rtl;
