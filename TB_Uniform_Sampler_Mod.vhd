--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:16:16 12/16/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_Uniform_Sampler_Mod.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Uniform_Sampler_Mod
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_Uniform_Sampler_Mod IS
END TB_Uniform_Sampler_Mod;
 
ARCHITECTURE behavior OF TB_Uniform_Sampler_Mod IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Uniform_Sampler_Mod
		generic(
				SEED	:INTEGER := 1
				);
		port(
			CLK : in  STD_LOGIC;
			RESET : in  STD_LOGIC;
			START : in  STD_LOGIC;
			RDY : out  STD_LOGIC;
			Z : out  N_BIT_INT
			);
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '1';
   signal RESET : std_logic := '0';
   signal START : std_logic := '0';

 	--Outputs
   signal RDY : std_logic;
   signal Z : N_BIT_INT;

   -- Clock period definitions
   constant PERIOD : time := 10 ns;

	constant SAMPLES		:INTEGER := 100000;
	constant HIST_LENGTH	:INTEGER := MODULUS_Q;
	signal hist				:INTEGER_ARRAY(HIST_LENGTH-1 downto 0);
	signal z_int			:INTEGER := 0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Uniform_Sampler_Mod PORT MAP (
          CLK => CLK,
          RESET => RESET,
		  START => START,
          RDY => RDY,
          Z => Z
        );

   -- Clock process definitions

	CLK <= not CLK after PERIOD/2;
 

   -- Stimulus process
	stim_proc: process

	begin		
		-- hold reset state for 100 ns.
		for i in 0 to HIST_LENGTH-1 loop
			hist(i) <= 0;
		end loop;
				
		wait for PERIOD;
		RESET <= '1';
		wait for PERIOD;
		RESET <= '0';
		wait for PERIOD;
		
		--for i in 0 to SAMPLES-1 loop
			START <= '1';
			wait for PERIOD;
			START <= '0';
			wait until RDY = '1';
			z_int <= conv_integer(Z);
			hist(z_int) <= hist(z_int) +1;
			wait for PERIOD;
		--end loop;
		
		wait for PERIOD;
		assert (false) report
		"Simulation successful (not a failure).  No problems detected. Look at hist() for evaluation."
		severity failure;

	end process;

END;
