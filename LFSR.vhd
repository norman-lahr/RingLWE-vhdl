----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:43:18 12/05/2011 
-- Design Name: 
-- Module Name:    LFSR - RTL 
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

entity LFSR is
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
end LFSR;

architecture RTL of LFSR is

	signal reg:	STD_LOGIC_VECTOR(LEN-1 downto 0);
begin
	
	process(CLK, INIT, START)
		constant regs	:INTEGER_ARRAY(3 downto 0) := feedbackArray(LEN); 
		variable feedback :	STD_LOGIC;
		
		begin
		if CLK'event and CLK = '1' then
			if INIT = '1' then
				reg <= conv_std_logic_vector(SEED, LEN); --Init
			else
				feedback := reg(regs(0));
				for i in 1 to 3 loop
					if (regs(i) /= -1) then
						feedback := feedback xnor reg(regs(i));
					end if;
				end loop;
				if (START = '1') then
					reg <= reg(LEN-2 downto 0) & feedback;
				end if;
			end if;
		end if;
	end process;
	
	Z <= reg;

end RTL;

