----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:50:02 12/16/2011 
-- Design Name: 
-- Module Name:    LWE_KeyGen - Behavioral 
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

entity LWE_KeyGen is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   START : in  STD_LOGIC;
		   RDY : out  STD_LOGIC;
           A : out  POLYNOMIAL;
           P : out  POLYNOMIAL;
           R2 : out  POLYNOMIAL
		   );
end LWE_KeyGen;

architecture Behavioral of LWE_KeyGen is
	component Gauss_Sampler_Poly is
		generic(
				LEN	:INTEGER := DEGREE_F;
				SEED:INTEGER := 0
				);
		Port ( CLK : in  STD_LOGIC;
			   RESET : in  STD_LOGIC;
			   Z : out  POLYNOMIAL);
	end component Gauss_Sampler_Poly;
	
	component Uniform_Sampler_Mod_Poly is
		generic(
				LEN	:INTEGER := DEGREE_F;
				SEED:INTEGER := 0
				);
		Port ( CLK : in  STD_LOGIC;
			   RESET : in  STD_LOGIC;
			   START : in  STD_LOGIC;
			   RDY : out  STD_LOGIC;
			   Z : out  POLYNOMIAL);
	end component Uniform_Sampler_Mod_Poly;
	
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

	signal int_r1, int_r2, int_a		:POLYNOMIAL;
	
	signal int_start_uni, int_rdy_uni 	:STD_LOGIC;
	signal int_start_mul, int_rdy_mul 	:STD_LOGIC;
	
	signal load_0, load_1, load_2	  	:STD_LOGIC;
	
	type STATE_T is(IDLE, GEN, WAIT_FOR_RDY_UNI, STAGE_0, START_MUL, WAIT_FOR_RDY_MUL, STAGE_1, STAGE_2, DONE);
	signal state: STATE_T;

	-- Stages
	-- Stage 0
	signal r1_0, r2_0, a_0			:POLYNOMIAL;
	-- Stage 1
	signal product_1_in, product_1	:POLYNOMIAL;
	-- STAGE 2
	signal p_in, p_out				:POLYNOMIAL;
	
begin

	Gen_r1: Gauss_Sampler_Poly
					generic map(
								SEED => 0
								)
						port map(
								CLK => CLK,
								RESET => RESET,
								Z => int_r1
								);
	
	Gen_r2: Gauss_Sampler_Poly
					generic map(
								SEED => 1
								)
						port map(
								CLK => CLK,
								RESET => RESET,
								Z => int_r2
								);
	Gen_a: Uniform_Sampler_Mod_Poly
					generic map(
								SEED => 0
								)
						port map(
								CLK => CLK,
								RESET => RESET,
								START => int_start_uni,
								RDY => int_rdy_uni,
								Z => int_a
								);
								
	Mul_Mod_Poly1: Mul_Mod_Poly
					port map(
							A => r2_0,
							B => a_0,
							Z => product_1_in,
							CLK => CLK,
							RESET => RESET,
							START => int_start_mul,
							RDY => int_rdy_mul
							);
							
	Add_Sub_Poly1: Add_Sub_Poly
					port map(
							A => r1_0,
							B => product_1,
							ADD_SUB => '1',
							Z => p_in
							);								

	control_unit: process(CLK, RESET, START, state)
	begin
	
		RDY <= '0';
		load_0 <= '0';
		load_1 <= '0';
		load_2 <= '0';
		int_start_uni <= '0';
		int_start_mul <= '0';
		
		case state is
		
			when IDLE 				=>	RDY <= '0';
									
			when GEN				=>	int_start_uni <= '1';
			
			when  WAIT_FOR_RDY_UNI	=>	int_start_uni <= '0';
			
			when STAGE_0 			=>	load_0 <= '1';
			
			when START_MUL			=>	int_start_mul <= '1';
										load_0 <= '0';
									
			when WAIT_FOR_RDY_MUL	=>	int_start_mul <= '0';
			
			when STAGE_1 			=>	load_1 <= '1';
				
			when STAGE_2 			=>	load_2 <= '1';
										load_1 <= '0';
			
			when DONE 				=>	load_2 <= '0';
										RDY <= '1';
			
			when others 			=>
			
		end case;

		if reset = '1' then
			state <= IDLE;
		elsif clk'event and clk = '1' then
		case state is
		
			when IDLE 				=>	if (START = '1') then
										state <= GEN;
									end if;
									
			when GEN				=> 	state <= WAIT_FOR_RDY_UNI;
			
			when WAIT_FOR_RDY_UNI	=> if (int_rdy_uni = '1') then
											state <= STAGE_0;
										end if;
									
			when STAGE_0 			=>	state <= START_MUL;
			
			when START_MUL			=>	state <= WAIT_FOR_RDY_MUL;
									
			when WAIT_FOR_RDY_MUL 	=>	if (int_rdy_mul = '1') then
										state <= STAGE_1;
									end if;
			
			when STAGE_1 			=>	state <= STAGE_2;
				
			when STAGE_2 			=>	state <= DONE;
			
			when DONE 				=>	state <= IDLE;
			
			when others 			=>
		end case;
		end if;
	end process;

	pipeline: process(CLK)
		begin
		if CLK'event and CLK = '1' then
			if load_0 = '1' then
				r1_0 <= int_r1;
				r2_0 <= int_r2;
				a_0 <= int_a;
			end if;
			
			if load_1 = '1' then
				product_1 <= product_1_in;
			end if;
			
			if load_2 = '1' then
				p_out <= p_in;
			end if;

		end if;
	end process;
	
	P <= p_out;
	R2 <= r2_0;
	A <= a_0;
end Behavioral;

