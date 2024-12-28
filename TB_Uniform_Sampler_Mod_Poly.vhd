--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:13:36 12/19/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_Uniform_Sampler_Mod_Poly.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Uniform_Sampler_Mod_Poly
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
 
ENTITY TB_Uniform_Sampler_Mod_Poly IS
END TB_Uniform_Sampler_Mod_Poly;
 
ARCHITECTURE behavior OF TB_Uniform_Sampler_Mod_Poly IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Uniform_Sampler_Mod_Poly
	generic(
			LEN	:INTEGER := DEGREE_F;
			SEED:INTEGER := 1
			);
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   START : in  STD_LOGIC;
           RDY : out  STD_LOGIC;
           Z : out  POLYNOMIAL);
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '1';
   signal RESET : std_logic := '0';
   signal START : std_logic := '0';

 	--Outputs
   signal RDY : std_logic;
   signal Z : POLYNOMIAL;

   -- Clock period definitions
   constant PERIOD : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Uniform_Sampler_Mod_Poly 
		generic map(
					SEED => 0
					)
		PORT MAP (
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
		wait for PERIOD;
		RESET <= '1';
		wait for PERIOD;
		RESET <= '0';
		wait for PERIOD;

		START <= '1';
		wait for PERIOD;
		START <= '0';
		wait until RDY = '1';
		wait for PERIOD;
		assert (false) report
		"Simulation successful (not a failure).  No problems detected."
		severity failure;
   end process;

END;
