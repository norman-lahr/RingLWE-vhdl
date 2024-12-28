----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:10:27 11/17/2011 
-- Design Name: 
-- Module Name:    FFT_Butterfly - Behavioral 
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
use WORK.Declaration_PKG.all;

entity FFT_Butterfly is
    Port ( A : in  N_BIT_INT;
           B : in  N_BIT_INT;
           W : in  N_BIT_INT;
		   C : out  N_BIT_INT;
           D : out  N_BIT_INT;
           CLK : in  STD_LOGIC;
           START : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   EN : in  STD_LOGIC;
		   BYPASS : in  STD_LOGIC;
           RDY : out  STD_LOGIC);
end FFT_Butterfly;

architecture Behavioral of FFT_Butterfly is
	-- Components
	component mul_mod is
	port (
		x, y					: in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
		clk, reset, start	: in STD_LOGIC; 
		z						: out STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
		done					: out STD_LOGIC
	);
	end component mul_mod;
	
	component add_sub_mod is
	port (
		x, y			: in STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0);
		add_sub	: in STD_LOGIC;
		z				: out STD_LOGIC_VECTOR(MODULUS_Q_WIDTH-1 downto 0)
	);
	end component add_sub_mod;
	
	-- Signals
	signal a_add, b_add, a_sub, b_sub, int_z, int_a, int_b, int_w, int_c: N_BIT_INT;
	signal int_rdy: STD_LOGIC;
	
	type STATE_T is(IDLE, WAIT_RDY, ADD_SUB, OUT_RDY);
	signal state: STATE_T;

	
begin
	mul_mod1: mul_mod port map(
								x => int_b, 
								y => int_w, 
								z => int_z, 
								clk => CLK, 
								reset => RESET, 
								start => START, 
								done => int_rdy
								);
												
	add_sub_mod1: add_sub_mod port map(x => a_add, 
										y => b_add, 
										z => int_c, 
										add_sub => '0');
															
	add_sub_mod2: add_sub_mod port map(x => a_sub, 
										y => b_sub, 
										z => D, 
										add_sub => '1');
															
	a_add <= int_a;
	a_sub <= int_a;
	b_add <= int_z;
	b_sub <= int_z;
	
	-- Bypass the adder
	with BYPASS select C <= int_c when '0', int_z when '1', (others => '0') when others;
	
	
	In_FF: PROCESS (CLK, RESET)
	BEGIN
		IF CLK'event and CLK = '1' THEN
			IF EN = '1' THEN
				int_a <= A;
				int_b <= B;
				int_w <= W;
			END IF;
		END IF;
	END PROCESS;
	
	control_unit: process(CLK, RESET, START, state)
	begin
	
		RDY <= '0';
		
		case state is
			when IDLE => 	RDY <= '0';
									
			when WAIT_RDY =>	
			
			when ADD_SUB =>
									
			when OUT_RDY =>	RDY <= '1';
			
			when others =>
			
		end case;

		if reset = '1' then
			state <= IDLE;
		elsif clk'event and clk = '1' then
		case state is
			when IDLE => if START = '1' then state <= WAIT_RDY; end if;
			when WAIT_RDY => if int_rdy = '1' then state <= ADD_SUB; end if;	-- Wait for rdy-signal of multiplier
			when ADD_SUB => state <= OUT_RDY;											-- Delay the RDY output
			when OUT_RDY => state <= IDLE;
			when others =>
		end case;
		end if;
	end process;
end Behavioral;

