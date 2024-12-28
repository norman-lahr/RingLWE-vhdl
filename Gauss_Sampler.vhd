----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:42:31 12/07/2011 
-- Design Name: 
-- Module Name:    Gauss_Sampler - Behavioral 
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

entity Gauss_Sampler is
	generic(
			LEN		:INTEGER := LFSR_LENGTH;
			SEED	:INTEGER := 1
			);
    port( 
		CLK : in  STD_LOGIC;
		INIT : in  STD_LOGIC;
		Z : out  N_BIT_INT
		);
end Gauss_Sampler;

architecture Behavioral of Gauss_Sampler is

	component LFSR is
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
	end component LFSR;

	component Gauss_Array is
		port( 
			CLK		:in STD_LOGIC;
			ADDR	:in  STD_LOGIC_VECTOR (LFSR_LENGTH-1 downto 0);
			   Z 	:out  N_BIT_INT
			);
	end component Gauss_Array;

	signal addr_int	:STD_LOGIC_VECTOR (LFSR_LENGTH-1 downto 0);
	
	begin
	
		LFSR1: LFSR generic map(
								SEED => SEED
								)
					port map(
							CLK => CLK,
							INIT => INIT,
							START => '1',
							Z => addr_int
							);
		
		Gauss_Array1: Gauss_Array port map(
											CLK => CLK,
											ADDR => addr_int,
											Z => Z
											);

end Behavioral;

