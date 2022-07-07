-- Testbench for Processor
library IEEE;
use IEEE.std_logic_1164.all;
use work.MyTypes.all;
use IEEE.numeric_std.all;
 
entity testbench is
-- empty
end testbench;

architecture tb of testbench is
  constant num_cycle  : integer := 300;
  constant clk_period : time := 2 ns;

component Proc is
  Port (
    input : in std_logic_vector(8 downto 0);
    reset	: in std_logic;
    clk		: in std_logic
    );
end component;
	
    signal input : std_logic_vector(8 downto 0) := '0' & X"00";
	  signal clk	 : std_logic := '0';
    signal reset : std_logic := '1';
    
begin

-- Put your test cases below line 40 of "Memory.vhd" similar to sample input sequences provided and comment them

----- Clock generator -----

  clkk : process
  begin
  	for i in 0 to num_cycle loop
    	clk <= not clk;
        wait for clk_period/2;
    end loop;
    wait;
  end process clkk;
  
  DUT: Proc port map (input, reset, clk);

  Proc_test: process
  begin
    reset <= '0' after 1.5*clk_period;
  	wait for clk_period;
    input <= "001010101";
    wait for 50*clk_period;
    input <= "101010101";
    wait for 30*clk_period;
    input <= "001010101";
    wait for 30*clk_period;
    assert false report lf & "************************************************************" & lf & "Processor Tested : Please Check Timing Diagram for more info!" & lf & "************************************************************" severity note;
    wait;
  end process Proc_test;

end tb;