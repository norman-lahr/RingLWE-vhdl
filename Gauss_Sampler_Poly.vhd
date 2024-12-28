----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:50:43 12/12/2011 
-- Design Name: 
-- Module Name:    Gauss_Sampler_Poly - Structure 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;		-- Numerical Computation
use WORK.DECLARATION_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gauss_Sampler_Poly is
	generic(
			LEN	:INTEGER := DEGREE_F;
			SEED:INTEGER := 0
			);
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
           Z : out  POLYNOMIAL);
end Gauss_Sampler_Poly;

architecture Structure of Gauss_Sampler_Poly is

	component Gauss_Sampler is
		generic(
				LEN		:INTEGER := LFSR_LENGTH;
				SEED	:INTEGER := 0
				);
		port( 
			CLK : in  STD_LOGIC;
			INIT : in  STD_LOGIC;
			Z : out  N_BIT_INT
			);
	end component Gauss_Sampler;
	

begin
	Gauss_Sampler_Array: for i in 0 to LEN-1 generate
		Gauss_Sampler1: Gauss_Sampler 
			generic map(
						SEED => SEED * LEN + i+1--GAUSS_RANDOM_SEED_ARRAY(SEED * DEGREE_F + i) TODO!
						)
			port map(
			  CLK => CLK,
			  INIT => RESET,
			  Z => Z(i)
			);
	end generate;
	
end Structure;

