--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   09:57:51 12/21/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE_ENCRYPT/TB_Gauss_Sampler_Poly.vhd
-- Project Name:  LWE_ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Gauss_Sampler_Poly
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
 
ENTITY TB_Gauss_Sampler_Poly IS
END TB_Gauss_Sampler_Poly;
 
ARCHITECTURE behavior OF TB_Gauss_Sampler_Poly IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Gauss_Sampler_Poly
    PORT(
         CLK : IN  std_logic;
         RESET : IN  std_logic;
         Z : OUT  POLYNOMIAL
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RESET : std_logic := '0';

 	--Outputs
   signal Z :POLYNOMIAL;

   -- Clock period definitions
   constant PERIOD : time := 10 ns;
 
 	constant SAMPLES	:INTEGER := 10;
	constant HIST_LENGTH	:INTEGER := integer(2.0*ceil(2.0*CONST_S)+1.0);
	signal hist				:INTEGER_ARRAY(HIST_LENGTH-1 downto 0);
	
	signal addr_int			:INTEGER := 0;
	signal tmpPoly		:POLYNOMIAL;
	signal tmpVal			:INTEGER := 0;
	

	
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Gauss_Sampler_Poly PORT MAP (
          CLK => CLK,
          RESET => RESET,
          Z => Z
        );

	clk <= not clk after PERIOD/2;
 

	stim_proc: process
	
		VARIABLE TX_LOC : LINE;
		VARIABLE TX_STR : String(1 to 4096);
		
		begin		
			-- hold reset state for 100 ns.
			
						
			wait for PERIOD;
			RESET <= '1';
			wait for PERIOD;
			RESET <= '0';
			wait for PERIOD;
			
			for j in 0 to SAMPLES loop
				
				for k in 0 to HIST_LENGTH-1 loop
					hist(k) <= 0;
				end loop;
				
				tmpPoly <= Z;
				wait for PERIOD;
				
				for i in 0 to DEGREE_F-1 loop
					tmpVal <= conv_integer(tmpPoly(i));
					if (tmpVal > HIST_LENGTH/2) then
						addr_int <= tmpVal - MODULUS_Q;
					else 
						addr_int <= tmpVal;
					end if;
					
					hist(addr_int + HIST_LENGTH/2) <= hist(addr_int + HIST_LENGTH/2) +1;
					wait for PERIOD;
				end loop;
				
				wait for PERIOD;
				
				write(TX_LOC,string'(LF & "Hist = ")); 
				for i in 0 to HIST_LENGTH-1 loop
					write(TX_LOC, hist(i));
					write(TX_LOC, string'(" | "));
				end loop;

				TX_STR(TX_LOC.all'range) := TX_LOC.all;

				Deallocate(TX_LOC);
				ASSERT (FALSE) REPORT TX_STR SEVERITY NOTE;
			
				wait for PERIOD;
				TX_STR := (others => ' ');
				
			end loop;
			
			assert (false) report
			"Simulation successful (not a failure).  No problems detected. Look at hist() for evaluation."
			severity failure;

		end process;

END;
