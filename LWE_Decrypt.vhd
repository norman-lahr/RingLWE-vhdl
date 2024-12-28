----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:45:51 12/15/2011 
-- Design Name: 
-- Module Name:    LWE_Decrypt - Behavioral 
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

entity LWE_Decrypt is
	port( 
		CLK : in  STD_LOGIC;
		RESET : in  STD_LOGIC;
		START : in  STD_LOGIC;
		RDY : out  STD_LOGIC;
		--LOAD : out  STD_LOGIC;
		C1 : in  POLYNOMIAL;
		C2 : in  POLYNOMIAL;
		R2 : in  POLYNOMIAL;
		M : out  STD_LOGIC_VECTOR (MSG_LEN-1 downto 0)
		);
end LWE_Decrypt;

architecture Behavioral of LWE_Decrypt is

	component Mul_Mod_Poly is
		port( 
			A		:in POLYNOMIAL;
			B		:in POLYNOMIAL;
			Z		:out POLYNOMIAL;
			CLK		:in STD_LOGIC;
			RESET	:in  STD_LOGIC;
			START	:in STD_LOGIC;
			RDY		:out STD_LOGIC
			);
	end component Mul_Mod_Poly;
	
	component add_sub_poly is
		port(
			a, b	: in POLYNOMIAL;
			add_sub	: in STD_LOGIC;  
			z		: out POLYNOMIAL
		);
	end component add_sub_poly;
	
	component Decode is
		port(
			M :in POLYNOMIAL;
			Z :out STD_LOGIC_VECTOR (MSG_LEN-1 downto 0)
			);
	end component Decode;
	
	-- Flip Flops, signals after Flip Flops
	-- Stage 0
	signal c1_0, c2_0, r2_0	:POLYNOMIAL;
	
	-- Stage 1
	signal product_c1_r2_in	:POLYNOMIAL;	-- After multiplication
	signal product_c1_r2	:POLYNOMIAL;	-- After multiplication
	
	-- Stage 2
	signal m_bar_in			:POLYNOMIAL;	-- After addition
	signal m_bar			:POLYNOMIAL;	-- After addition
	
	-- Stage 3
	signal m_out_in			:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);		-- After decode
	signal m_out			:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);		-- After decode
	
	signal int_start, int_rdy				:STD_LOGIC;
	signal load_0, load_1, load_2, load_3	:STD_LOGIC;
	
	type STATE_T is(IDLE, STAGE_0, START_MUL, WAIT_FOR_RDY, STAGE_1, STAGE_2, STAGE_3, DONE);
	signal state: STATE_T;
	
begin
	Mul_Mod_Poly1: Mul_Mod_Poly
					port map(
							A => c1_0,
							B => r2_0,
							Z => product_c1_r2_in,
							CLK => CLK,
							RESET => RESET,
							START => int_start,
							RDY => int_rdy
							);
							
	Add_Sub_Poly1: Add_Sub_Poly
					port map(
							A => product_c1_r2,
							B => c2_0,
							ADD_SUB => '0',
							Z => m_bar_in
							);
							
	Decoder1: Decode
					port map(
							M => m_bar,
							Z => m_out_in
							);

	control_unit: process(CLK, RESET, START, state)
	begin
	
		RDY <= '0';
		load_0 <= '0';
		load_1 <= '0';
		load_2 <= '0';
		load_3 <= '0';
		int_start <= '0';
		
		case state is
		
			when IDLE 			=>	RDY <= '0';
									
									
			when STAGE_0 		=>	load_0 <= '1';
			
			when START_MUL		=>	int_start <= '1';
									load_0 <= '0';
									
			when WAIT_FOR_RDY 	=>	int_start <= '0';
			
			when STAGE_1 		=>	load_1 <= '1';
				
			when STAGE_2 		=>	load_2 <= '1';
									load_1 <= '0';
			
			when STAGE_3 		=>	load_3 <= '1';
									load_2 <= '0';
			
			when DONE 			=>	load_3 <= '0';
									RDY <= '1';
			
			when others 		=>
			
		end case;

		if reset = '1' then
			state <= IDLE;
		elsif clk'event and clk = '1' then
		case state is
		
			when IDLE 			=>	if (START = '1') then
										state <= STAGE_0;
									end if;
									
			when STAGE_0 		=>	state <= START_MUL;
			
			when START_MUL		=>	state <= WAIT_FOR_RDY;
									
			when WAIT_FOR_RDY 	=>	if (int_rdy = '1') then
										state <= STAGE_1;
									end if;
			
			when STAGE_1 		=>	state <= STAGE_2;
				
			when STAGE_2 		=>	state <= STAGE_3;
			
			when STAGE_3 		=>	state <= DONE;
			
			when DONE 			=>	state <= IDLE;
			
			when others 		=>
		end case;
		end if;
	end process;
	
	pipeline: process(CLK)
		begin
		if CLK'event and CLK = '1' then
			if load_0 = '1' then
				c1_0	<= C1;
				c2_0	<= C2;
				r2_0	<= R2;
			end if;
			
			if load_1 = '1' then
				product_c1_r2 <= product_c1_r2_in;
			end if;
			
			if load_2 = '1' then
				m_bar <= m_bar_in;
			end if;
			
			if load_3 = '1' then
				m_out <= m_out_in;
			end if;
		end if;
	end process;							

	M <= m_out;
	
end Behavioral;

