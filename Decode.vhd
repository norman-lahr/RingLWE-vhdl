----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:40:25 12/01/2011 
-- Design Name: 
-- Module Name:    Decode - RTL 
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

entity Decode is
    Port ( M :in POLYNOMIAL;
           Z :out STD_LOGIC_VECTOR (MSG_LEN-1 downto 0)
		  );
end Decode;

architecture RTL of Decode is

begin
	
	DEC_DEMUX: for i in 0 to MSG_LEN-1 generate
		DEMUX: process(M(i))
			begin
			if(M(i) >= NEG_THRESHOLD or M(i) < THRESHOLD) then
				Z(i) <= '0';
			else
				Z(i) <= '1';
			end if;
		end process;
	end generate;
	
end RTL;

