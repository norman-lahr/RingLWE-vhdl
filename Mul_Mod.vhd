----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:57:44 11/14/2011 
-- Design Name: 
-- Module Name:    Mul_Mod - RTL 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Montgomery Multiplier
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

entity Mul_Mod is
port (
  x, y: in std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
  clk, reset, start: in std_logic;
  z: out std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
  done: out std_logic
);
end Mul_Mod;

architecture rtl of Mul_Mod is

	COMPONENT Mont_Mul is
	PORT (
		x, y: in std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
		clk, reset, start: in std_logic; 
		z: out std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
		done: out std_logic
	);
	END COMPONENT;
	
	type state_t is(IDLE, PRE, PRE2, MAIN, MAIN2);
	signal current_state: state_t;
	signal int_x, int_y, int_z, int_z2: std_logic_vector(MODULUS_Q_WIDTH-1 downto 0);
	signal int_start, int_done, pre_x, pre_y, load: STD_LOGIC;
	
begin
	Mont_Mul1: Mont_Mul PORT MAP(x =>int_x, y => int_y, 
						  clk => clk, reset => reset, start => int_start,
						  z => int_z, done => int_done);

	with pre_x select int_x <= x when '0', int_z2 when others;
	with pre_y select int_y <= R2_PRE when '0', y when others;
	z <= int_z;
	
	result_register: process(clk) --todo Output not Input?
	begin
		if clk'event and clk = '1' then
			if load = '1' then 
				int_z2 <= int_z;
			end if;
		end if;
	end process result_register;
	
	control_unit: process(clk, reset, current_state)
	begin
		done <= '0';
		int_start <= '0';
		load <= '0';
		pre_x <= '0';
		pre_y <= '0';
		
		case current_state is
			when IDLE => 	done <= '1';
							int_start <='0';
							pre_x <= '1';
							pre_y <= '1';
									
			when PRE =>		done <= '0';
							pre_x <= '0';
							pre_y <= '0';
							int_start <='1';
									
			when PRE2 =>	int_start <= '0';
			
			when MAIN =>	done <= '0';
							load <= '1';
							pre_x <= '1';
							pre_y <= '1';
							int_start <= '1';
									
			when MAIN2 =>	int_start <= '0';	
							load <= '0';
							pre_x <= '1';
							pre_y <= '1';
			when others =>
			
		end case;

		if reset = '1' then
			current_state <= IDLE;
		elsif clk'event and clk = '1' then
		case current_state is
			when IDLE => if start = '1' then current_state <= PRE; end if;
			when PRE => current_state <= PRE2;
			when PRE2 => if int_done = '1' then current_state <= MAIN; end if;
			when MAIN => current_state <= MAIN2;
			when MAIN2 => if int_done = '1' then current_state <= IDLE; end if;
			when others =>
		end case;
		end if;
	end process;

end rtl;