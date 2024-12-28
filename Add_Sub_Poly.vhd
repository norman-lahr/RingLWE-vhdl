----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:15:53 11/09/2011 
-- Design Name: 
-- Module Name:    Add_Sub_Poly - RTL 
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
use IEEE.STD_LOGIC_1164.ALL;				-- Signal Types
use IEEE.STD_LOGIC_ARITH.ALL;			-- Numerical Computation
use IEEE.STD_LOGIC_UNSIGNED.ALL;	-- Unsigned Numerical Computation on type STD_LOGIC_VECTOR
use WORK.Declaration_PKG.ALL;

entity add_sub_poly is
port(
	a, b	: in POLYNOMIAL;
	add_sub	: in STD_LOGIC;  
	z		: out POLYNOMIAL
);
end add_sub_poly;

architecture Structure of add_sub_poly is
	component add_sub_mod is
		port (
		x, y	: in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
		add_sub	: in STD_LOGIC;
		z		: out STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0)
		);
	end component;
begin

  main_component: for i in 0 to DEGREE_F-1 generate
    comp1: add_sub_mod port map(x => a(i), y => b(i),
                                      add_sub => add_sub, z => z(i));
  end generate;
end structure;

