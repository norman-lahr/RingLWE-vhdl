----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:26:19 11/09/2011 
-- Design Name: 
-- Module Name:    Add_Sub_Mod - RTL 
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

entity add_sub_mod is
port (
	x, y			: in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
	add_sub	: in STD_LOGIC;
	z				: out STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0)
);
end add_sub_mod;

architecture RTL of add_sub_mod is

	signal long_x, xor_y, sum1, long_z1, xor_q, sum2: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH downto 0);
	signal c1, c2, sel: STD_LOGIC;
	signal z1, z2: STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
	
begin

	long_x <= '0' & x;
	
	xor_gates1: for i in 0 to MODULUS_Q_WIDTH-1 generate 
	xor_y(i) <= y(i) xor add_sub; 
	end generate;
	
	xor_y(MODULUS_Q_WIDTH) <= '0';
	
	sum1 <= add_sub + long_x + xor_y;
	
	c1 <= sum1(MODULUS_Q_WIDTH);
	z1 <= sum1(MODULUS_Q_WIDTH-1 downto 0);
	
	long_z1 <= '0'&z1;
	
	xor_gates2: for i in 0 to MODULUS_Q_WIDTH-1 generate 
	xor_q(i) <= Q(i) xor not(add_sub); 
	end generate;
	
	xor_q(MODULUS_Q_WIDTH) <= '0';
	
	sum2 <= not(add_sub) + long_z1 + xor_q;
	
	c2 <= sum2(MODULUS_Q_WIDTH);
	z2 <= sum2(MODULUS_Q_WIDTH-1 downto 0);
	
	sel <= (not(add_sub) and (c1 or c2)) or (add_sub and not(c1));
	with sel select z <= z1 when '0', z2 when others;
end RTL;

