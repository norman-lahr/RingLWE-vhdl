----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:48 12/16/2011 
-- Design Name: 
-- Module Name:    Uniform_Sampler_Mod - Behavioral 
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

entity Uniform_Sampler_Mod is
	generic(
			SEED	:INTEGER := 1
			);
    port(
		CLK : in  STD_LOGIC;
		RESET : in  STD_LOGIC;
		START : in  STD_LOGIC;
		RDY : out  STD_LOGIC;
		Z : out  N_BIT_INT
		);
end Uniform_Sampler_Mod;

architecture Behavioral of Uniform_Sampler_Mod is

	component LFSR is
		generic(
				LEN		:INTEGER := LFSR_LENGTH;
				SEED	:INTEGER := 1
				);
		port( 
			CLK : in  STD_LOGIC;
			INIT : in  STD_LOGIC;
			START : in  STD_LOGIC;
			Z : out  N_BIT_INT
			);
	end component LFSR;
	
	signal int_z	:N_BIT_INT;
	signal load		:STD_LOGIC;
	signal int_start:STD_LOGIC;
	type STATE_T is(IDLE, RUN, DONE);
	signal state: STATE_T;
	
begin
	LFSR1: LFSR
		generic map(
					LEN => MODULUS_Q_WIDTH,
					SEED => SEED
					)
			port map(
					CLK => CLK,
					INIT => RESET,
					START => int_start,
					Z => int_z
					);
					
	control_unit: process(CLK, RESET, START, state)
	begin
	
		RDY <= '0';
		load <= '0';
		int_start <= '0';
		
		case state is
		
			when IDLE 			=>	RDY <= '1';
									load <= '0';
									int_start <= '0';
			
			when RUN			=>	load <= '1';
									RDY <= '0';
									int_start <= '1';
			
			when others 		=>
			
		end case;

		if RESET = '1' then
			state <= IDLE;
		elsif CLK'event and CLK = '1' then
		case state is
		
			when IDLE 			=>	if (START = '1') then
										state <= RUN;
									end if;
									
			when RUN			=> if (int_z < Q) then
										state <= IDLE;
									end if;
			
			when others 		=>
		end case;
		end if;
	end process;

	process(CLK, load)
		
		begin
		if CLK'event and CLK = '1' then
			
			if (load = '1') then
				Z <= int_z;
			end if;
			
		end if;
	end process;
	
end Behavioral;

