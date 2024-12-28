----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:58:22 11/22/2011 
-- Design Name: 
-- Module Name:    And_N - RTL 
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
use WORK.DECLARATION_PKG.all;

entity And_N is
	generic(
			N	:INTEGER
			);
    port( 
		A	:in STD_LOGIC_VECTOR(N-1 downto 0);
		Z	:out STD_LOGIC
		);
end And_N;

architecture RTL of And_N is
	
	signal int_a	:STD_LOGIC_VECTOR(N-1 downto 0);
	
begin
	
	int_a(0) <= A(0);
	gen_and_n: for i in 1 to N-1 generate
		int_a(i) <= int_a(i-1) and A(i);
	end generate;
	
	Z <= int_a(N -1);
	
end RTL;

