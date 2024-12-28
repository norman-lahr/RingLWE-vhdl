----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:11 12/05/2011 
-- Design Name: 
-- Module Name:    Gauss_Array - RTL 
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
use IEEE.STD_LOGIC_ARITH.all;	-- Conversation to STD_LOGIC_VECTOR
use WORK.DECLARATION_PKG.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Gauss_Array is
    port( 
		CLK		:in STD_LOGIC;
		ADDR	:in  STD_LOGIC_VECTOR (LFSR_LENGTH-1 downto 0);
           Z 	:out  N_BIT_INT);
end Gauss_Array;

architecture RTL of Gauss_Array is

	signal int_z	:N_BIT_INT;
	
	begin
		
		process(ADDR)
			constant LIMITS			: INTEGER_ARRAY:=getLimits(GAUSSIAN_RESOLUTION, CONST_S);
			constant CONTENT		: N_BIT_INT_ARRAY:=getContent(GAUSSIAN_RESOLUTION, CONST_S); -- TODO: In B-RAM?
			constant CONTENT_LENGTH	:INTEGER := getConentLength(GAUSSIAN_RESOLUTION, CONST_S);
			variable addr_int		:INTEGER;
			begin
				addr_int := conv_integer(unsigned(ADDR));
				for i in 0 to CONTENT_LENGTH-1 loop
					if(addr_int >= limits(2*i) and addr_int <= limits(2*i+1)) then
						int_z <= CONTENT(i);
						exit;
					else
						int_z <= (others => '0');
					end if;
				end loop;
		end process;
		
		output: process(CLK)
			begin
			if CLK'event and CLK = '1' then
					Z <= int_z;
			end if;
			
		end process;

end RTL;

