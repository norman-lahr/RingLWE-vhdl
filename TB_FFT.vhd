--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:56:41 11/22/2011
-- Design Name:   
-- Module Name:   /home/noggybear/ISE-Workspace/LWE-Encrypt/TB_FFT.vhd
-- Project Name:  LWE-ENCRYPT
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FFT
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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;
 
ENTITY TB_FFT IS
END TB_FFT;
 
ARCHITECTURE behavior OF TB_FFT IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FFT
    Port ( A : in  POLYNOMIAL_2K;
           Z : out  POLYNOMIAL_2K;
           CLK : in  STD_LOGIC;
           START : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   LOAD : in  STD_LOGIC;
		   IFFT	:in STD_LOGIC;
           RDY : out  STD_LOGIC);
    END COMPONENT;
    

   --Inputs
   signal A : POLYNOMIAL_2K;
   signal CLK : std_logic := '0';
   signal START : std_logic := '0';
   signal RESET : std_logic := '0';
   signal LOAD : std_logic := '0';
   signal IFFT	:STD_LOGIC := '0';

 	--Outputs
   signal Z : POLYNOMIAL_2K;
   signal cmp_Z : POLYNOMIAL_2K;
   signal RDY : std_logic;

   -- Clock period definitions
   constant PERIOD : time := 10 ns;
   
   constant NUMBER_TESTS	:INTEGER := 20;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FFT PORT MAP (
          A => A,
          Z => Z,
          CLK => CLK,
          START => START,
          RESET => RESET,
		  LOAD => LOAD,
		  IFFT => IFFT,
          RDY => RDY
        );

	CLK <= not CLK after PERIOD/2;
	
	TB_Proc: process
		procedure gen_polynom(X : out POLYNOMIAL_2K; w: NATURAL; s1, s2: inout NATURAL) is
			variable i_x, i_p: INTEGER;
			variable rand: REAL;
		begin      
			i_p := conv_integer(('0' & Q));
			for i in 0 to 2*DEGREE_F-1 loop
				uniform(s1, s2, rand);
				i_x := INTEGER(trunc(rand * REAL(i_p)));
				X(i) := conv_std_logic_vector (i_x, MODULUS_Q_WIDTH);
			end loop;
		end procedure;

		variable seed1, seed2: POSITIVE; 
		variable aPol: POLYNOMIAL_2K;
		variable i_x: NATURAL;
		variable rand: REAL;
		
		--variable TX_LOC : LINE;
		--variable TX_STR : String(1 to 4096);
		
		begin
			IFFT <= '0'; start <= '0'; reset <= '1';
			wait for PERIOD;
			reset <= '0';

			for i in 1 to NUMBER_TESTS loop
				-- FFT
				wait for PERIOD;
				-- Load values into the flipflops
				LOAD <= '1';
				
				gen_polynom(aPol, DEGREE_F, seed1, seed2);
				cmp_Z <= int_fft(aPol, false);
				
				A <= aPol;
				
				wait for PERIOD;
				LOAD <= '0';
				wait for PERIOD;
				START <= '1';
				wait for PERIOD;
				START <= '0';
	  
				wait until RDY = '1';
				
				if (Z /= cmp_Z) then
					assert (false) report "Result of VHDL FFT is not equal to iterative FFT!" severity ERROR;
				end if; 
				
--				-- IFFT
--				wait for PERIOD;
--				-- Load values into the flipflops
--				LOAD <= '1';
--				
--				cmp_Z <= int_fft(cmp_Z, true);
--				
--				A <= Z;
--				
--				wait for PERIOD;
--				LOAD <= '0';
--				wait for PERIOD;
--				START <= '1';
--				wait for PERIOD;
--				START <= '0';
--	  
--				wait until RDY = '1';
--				
--				if (Z /= aPol) then
--					assert (false) report "Result of VHDL FFT is not equal to iterative IFFT!" severity ERROR;
--				end if; 
			end loop;
			
			
		ASSERT (FALSE) REPORT
		"Simulation successful (not a failure).  No problems detected. "
		SEVERITY FAILURE;
	end process;
   
END;