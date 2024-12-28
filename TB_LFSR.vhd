--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:23:30 12/07/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_LFSR.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: LFSR
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;
use STD.TEXTIO.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity TB_LFSR is
end TB_LFSR;
 
architecture behavior of TB_LFSR is 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component LFSR
	generic(
			LEN		:INTEGER := LFSR_LENGTH;
			SEED	:INTEGER := 1
			);
			
    port(
		CLK : in  STD_LOGIC;
		INIT	: in STD_LOGIC;
		START	: in STD_LOGIC;
		Z	: out STD_LOGIC_VECTOR(LEN-1 downto 0)
		);
    end component;
    

	constant LEN	:INTEGER := 12;
	--Inputs
	signal CLK : STD_LOGIC := '0';
	signal INIT : STD_LOGIC := '0';

	--Outputs
	signal Z : STD_LOGIC_VECTOR(LEN-1 downto 0);

	constant PERIOD : time := 10 ns;

	constant SAMPLES		:INTEGER := 100000;
	constant HIST_LENGTH	:INTEGER := 2**LEN-1;--GAUSSIAN_RESOLUTION;
	signal hist				:INTEGER_ARRAY(HIST_LENGTH-1 downto 0);
	signal z_int			:INTEGER := 0;
	
begin
 
	-- Instantiate the Unit Under Test (UUT)
   uut: LFSR 
		generic map(
					LEN => LEN
					)
		port map (
          CLK => CLK,
          INIT => INIT,
		  START => '1',
          Z => Z
        );

	clk <= not clk after PERIOD/2;
 

   -- Stimulus process
   stim_proc: process
   begin	
		-- Init the histogram
		for i in 0 to HIST_LENGTH-1 loop
			hist(i) <= 0;
		end loop;   
		
		-- Set the Seed in the LFSR
		wait for PERIOD;
		INIT <= '1';
		wait for PERIOD;
		INIT <= '0';
		wait for PERIOD;

		-- fill the histogram with values
		for i in 0 to SAMPLES-1 loop
			z_int <= conv_integer(Z);
			hist(z_int) <= hist(z_int) +1;
			wait for PERIOD;
		end loop;
		
		wait for PERIOD;
		assert (false) report
		"Simulation successful (not a failure).  No problems detected. Look at hist() for evaluation."
		severity failure;
   end process;

end;
