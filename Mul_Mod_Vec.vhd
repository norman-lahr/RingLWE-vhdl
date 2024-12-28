----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:23:24 11/29/2011 
-- Design Name: 
-- Module Name:    Mul_Mod_Vec - Behavioral 
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

entity Mul_Mod_Vec is
    port( 
		A		:in POLYNOMIAL;
        B		:in POLYNOMIAL;
		Z		:out POLYNOMIAL;
        CLK		:in STD_LOGIC;
		RESET	:in  STD_LOGIC;
        START	:in STD_LOGIC;
		LOAD_A	:in STD_LOGIC;
		LOAD_B	:in STD_LOGIC;
        RDY		:out STD_LOGIC
		);
end Mul_Mod_Vec;

architecture Behavioral of Mul_Mod_Vec is

	component mul_mod is
		port(
			X		:in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
			Y		:in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
			Z		:out STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
			CLK		:in STD_LOGIC; 
			RESET	:in STD_LOGIC; 
			START	:in STD_LOGIC; 
			DONE	:out STD_LOGIC 
			);
	end component mul_mod;
	
	component And_N is
		generic(
				N: INTEGER
				);
		port(
			A	:in STD_LOGIC_VECTOR (N-1 downto 0);
			Z	:out  STD_LOGIC
			);
	end component And_N;
	
	signal int_rdy	:STD_LOGIC_VECTOR(DEGREE_F-1 downto 0);
	
	signal int_a, int_b	:POLYNOMIAL;
	
begin

	Mul_Vec: for i in 0 to DEGREE_F-1 generate
		mul_mod1: mul_mod port map(
								X => int_a(i), 
								Y => int_b(i), 
								Z => Z(i), 
								CLK => CLK, 
								RESET => RESET, 
								START => START, 
								DONE => int_rdy(i)
								);
	end generate;

	-- Global Ready signal of all multipliers
	AND_RDY: And_N generic map(
								N => DEGREE_F
								)
						port map(
								A => int_rdy, 
								Z => RDY
								);
								
	-- Store Input values
	In_FF: process (CLK, RESET)
	begin
		if CLK'event and CLK = '1' then
			if LOAD_A = '1' then
				int_a <= A;
			end if;
			if LOAD_B = '1' then
				int_b <= B;
			end if;
		end if;
	end process;
								
end Behavioral;

