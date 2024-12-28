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
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.all;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use IEEE.MATH_REAL.all;
use IEEE.NUMERIC_STD.all;
use WORK.DECLARATION_PKG.all;
 
entity TB_MUL_MOD_POLY is
end TB_MUL_MOD_POLY;
 
architecture behavior of TB_MUL_MOD_POLY is 
 
	-- Component Declaration for the Unit Under Test (UUT)

	component MUL_MOD_POLY
	port( 
		A		:in POLYNOMIAL;
		B		:in POLYNOMIAL;
		Z		:out POLYNOMIAL;
		CLK		:in STD_LOGIC;
		RESET	:in  STD_LOGIC;
		START	:in STD_LOGIC;
		RDY		:out STD_LOGIC
		);
	end component;


	--Inputs
	signal A : POLYNOMIAL;
	signal B : POLYNOMIAL;

	signal CLK : std_logic := '0';
	signal START : std_logic := '0';
	signal RESET : std_logic := '0';

	--Outputs
	signal Z : POLYNOMIAL;
	signal RDY : std_logic;

	signal aPol_2K: POLYNOMIAL_2K;
	signal bPol_2K: POLYNOMIAL_2K;
	signal cmp_A : POLYNOMIAL_2K;
	signal cmp_B : POLYNOMIAL_2K;
	signal cmp_C : POLYNOMIAL_2K;
	signal cmp_Z : POLYNOMIAL;
	signal cmp_Z_2K : POLYNOMIAL_2K;

	-- Clock period definitions
	constant PERIOD : time := 10 ns;

	constant NUMBER_TESTS	:INTEGER := 10;--20;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MUL_MOD_POLY PORT MAP (
          A => A,
		  B => B,
          Z => Z,
          CLK => CLK,
          START => START,
          RESET => RESET,
          RDY => RDY
        );

	CLK <= not CLK after PERIOD/2;
	
	TB_Proc: process
		procedure gen_polynom(X : out POLYNOMIAL; w: NATURAL; s1, s2: inout NATURAL) is
			variable i_x, i_p: INTEGER;
			variable rand: REAL;
		begin      
			i_p := conv_integer(('0' & Q));
			for i in 0 to DEGREE_F-1 loop
				uniform(s1, s2, rand);
				i_x := INTEGER(trunc(rand * REAL(i_p)));
				X(i) := conv_std_logic_vector (i_x, MODULUS_Q_WIDTH);
				--X(i) := conv_std_logic_vector (i, MODULUS_Q_WIDTH);
			end loop;
		end procedure;

		variable seed1, seed2: POSITIVE; 
		variable aPol: POLYNOMIAL;
		variable bPol: POLYNOMIAL;

		variable i_x: NATURAL;
		variable rand: REAL;
		
		--variable TX_LOC : LINE;
		--variable TX_STR : String(1 to 4096);
		
		begin
			START <= '0'; RESET <= '1';
			wait for PERIOD;
			RESET <= '0';

			for i in 1 to NUMBER_TESTS loop
				-- Multiply mod polynomial
				wait for PERIOD;
				
				-- Generate Polynomials
				-- First half
				gen_polynom(aPol, DEGREE_F, seed1, seed2);
				for j in aPol'low to aPol'high loop
					aPol_2K(j) <= aPol(j);
				end loop;
				-- Second half
				aPol_2K(aPol_2K'high downto aPol'high+1)<= (others => (others => '0'));
				wait for PERIOD;
				-- Calculate FFT(A) as refernce
				cmp_A <= int_fft(aPol_2K, false);
				
				-- First half
				gen_polynom(bPol, DEGREE_F, seed1, seed2);
				for j in bPol'range loop
					bPol_2K(j) <= bPol(j);
				end loop;
				-- Second half
				bPol_2K(bPol_2K'high downto bPol'high+1)<= (others => (others => '0'));
				wait for PERIOD;
				-- Calculate FFT(B) as refernce
				cmp_B <= int_fft(bPol_2K, false);
				wait for PERIOD;
				-- Calculate product componentwise
				for j in cmp_A'range loop
					cmp_C(j) <= conv_std_logic_vector((conv_integer(cmp_A(j)) * conv_integer(cmp_B(j))) mod MODULUS_Q, MODULUS_Q_WIDTH);
				end loop;
				wait for PERIOD;
				-- Inverse transformation
				cmp_Z_2K <= int_fft(cmp_C, true);
				wait for PERIOD;
				-- Reduce mod f(x) = x^n + 1
				for j in cmp_Z'range loop
					cmp_Z(j) <= conv_std_logic_vector((conv_integer(cmp_Z_2K(j)) - conv_integer(cmp_Z_2K(j+DEGREE_F))) mod MODULUS_Q, MODULUS_Q_WIDTH);
				end loop;
				
				
				-- Test Device
				wait for PERIOD;
				A <= aPol;
				B <= bPol;
				
				wait for PERIOD;
				START <= '1';
				wait for PERIOD;
				START <= '0';
	  
				wait until RDY = '1';
				
				if (Z /= cmp_Z) then
					assert (false) report "Result of VHDL Mul Mod Poly is not equal to iterative Mul Mod Poly!" severity ERROR;
				end if; 
 
			end loop;
			
			
		ASSERT (FALSE) REPORT
		"Simulation successful (not a failure).  No problems detected. "
		SEVERITY FAILURE;
	end process;
   
END;