----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:12:20 12/16/2011 
-- Design Name: 
-- Module Name:    Uniform_Sampler_Mod_Poly - Behavioral 
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
use WORK.DECLARATION_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Uniform_Sampler_Mod_Poly is
	generic(
			LEN	:INTEGER := DEGREE_F;
			SEED:INTEGER := 1
			);
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   START : in  STD_LOGIC;
           RDY : out  STD_LOGIC;
           Z : out  POLYNOMIAL);
end Uniform_Sampler_Mod_Poly;

architecture Behavioral of Uniform_Sampler_Mod_Poly is

	component Uniform_Sampler_Mod is
		generic(
				SEED	:INTEGER := 0
				);
		port(
			CLK : in  STD_LOGIC;
			RESET : in  STD_LOGIC;
			START : in  STD_LOGIC;
			RDY : out  STD_LOGIC;
			Z : out  N_BIT_INT
			);
	end component Uniform_Sampler_Mod;
	
	component And_N is
	generic(
			N	:INTEGER
			);
    port( 
		A	:in STD_LOGIC_VECTOR(N-1 downto 0);
		Z	:out STD_LOGIC
		);
	end component And_N;
	
	signal int_rdy	:STD_LOGIC_VECTOR(LEN-1 downto 0);

begin
	
	Uniform_Sampler_Mod_Array: for i in 0 to LEN-1 generate
		Uniform_Sampler_Mod1: Uniform_Sampler_Mod
								generic map(
											SEED => UNI_RANDOM_SEED_ARRAY(SEED * DEGREE_F + i)
											)
								port map(
										CLK => CLK,
										RESET => RESET,
										START => START,
										RDY => int_rdy(i),
										Z => Z(i)
										);
	end generate;
	
	AND_RDY: AND_N
			generic map(
						N => LEN
						)
			port map(
					A => int_rdy,
					Z => RDY
					);


end Behavioral;

