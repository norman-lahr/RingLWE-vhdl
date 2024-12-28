----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:49:59 11/20/2011 
-- Design Name: 
-- Module Name:    MUX_N - RTL 
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
use WORK.DECLARATION_PKG.ALL;


entity MUX_N is
	generic(
			N	:INTEGER
			);
	port(
		A	:in	N_BIT_INT_ARRAY(N-1 downto 0);
		SEL	:in	INTEGER range 0 to N-1;
		Z	:out N_BIT_INT
	);
end MUX_N;

architecture RTL of MUX_N is

begin
	Z <= A(SEL);

end RTL;

