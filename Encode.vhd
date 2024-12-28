----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:12:30 12/01/2011 
-- Design Name: 
-- Module Name:    Encode - RTL 
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
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;	-- Conversation to STD_LOGIC_VECTOR
use WORK.DECLARATION_PKG.all;

entity Encode is
    Port ( M	:in STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
           Z 	:out POLYNOMIAL
		   );
end Encode;

architecture RTL of Encode is

begin

	ENC_MUX: for i in 0 to MSG_LEN-1 generate
		with M(i) select Z(i) <= ENC_VAL when '1',
								(others => '0') when others;
	end generate;
	
	Z(POLYNOMIAL'high downto MSG_LEN) <= (others => (others => '0'));

end RTL;

