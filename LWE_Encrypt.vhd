----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:50:29 12/12/2011 
-- Design Name: 
-- Module Name:    LWE_Encrypt - Behavioral 
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

entity LWE_Encrypt is
    Port ( CLK : in  STD_LOGIC;
           RESET : in  STD_LOGIC;
		   START : in  STD_LOGIC;
           RDY : out  STD_LOGIC;
           A : in  POLYNOMIAL;
           P : in  POLYNOMIAL;
           M : in  STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
           C1 : out  POLYNOMIAL;
		   C2 : out  POLYNOMIAL
		   );
end LWE_Encrypt;

architecture Behavioral of LWE_Encrypt is

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
	
	component Encode is
		port(
			M	:in STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
			Z 	:out POLYNOMIAL
			);
	end component Encode;
	
	component Gauss_Sampler_Poly is
	generic(
			LEN	:INTEGER := DEGREE_F;
			SEED:INTEGER := 0
			);
    port(
		CLK : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        Z : out  POLYNOMIAL
		);
	end component Gauss_Sampler_Poly;
	
	
	signal int_e1, int_e2, int_e3	:POLYNOMIAL;
	
	-- Flip Flops, signals after Flip Flops
	-- Stage 0
	signal c1_0, c2_0	:POLYNOMIAL;
	signal m_0			:STD_LOGIC_VECTOR (MSG_LEN-1 downto 0);
	
	-- Stage 1
	signal c1_1_in, c2_1_in	:POLYNOMIAL;	-- After multiplication
	signal c1_1, c2_1		:POLYNOMIAL;	-- After multiplication
	signal m_1_in, m_1		:POLYNOMIAL;	-- After encoding
	
	-- Stage 2
	signal c1_2_in, c2_2_in	:POLYNOMIAL;	-- After first addition
	signal c1_2, c2_2		:POLYNOMIAL;	-- After first addition
	
	-- Stage 3
	signal c2_3_in		:POLYNOMIAL;		-- After second addition
	signal c2_3			:POLYNOMIAL;		-- After second addition
	
	signal int_start, int_rdy, int_rdy1, int_rdy2	:STD_LOGIC;
	signal load_0, load_1, load_2, load_3			:STD_LOGIC;
	
	type STATE_T is(IDLE, STAGE_0, START_MUL, WAIT_FOR_RDY, STAGE_1, STAGE_2, STAGE_3, DONE);
	signal state: STATE_T;
	
begin

	Mul_Mod_Poly1: Mul_Mod_Poly
					port map(
							A => c1_0,
							B => int_e1,
							Z => c1_1_in,
							CLK => CLK,
							RESET => RESET,
							START => int_start,
							RDY => int_rdy1
							);
							
	Mul_Mod_Poly2: Mul_Mod_Poly
					port map(
							A => c2_0,
							B => int_e1,
							Z => c2_1_in,
							CLK => CLK,
							RESET => RESET,
							START => int_start,
							RDY => int_rdy2
							);
							
	Add_Sub_Poly1: Add_Sub_Poly
					port map(
							A => c1_1,
							B => int_e2,
							ADD_SUB => '0',
							Z => c1_2_in
							);

	Add_Sub_Poly2: Add_Sub_Poly
					port map(
							A => c2_1,
							B => int_e3,
							ADD_SUB => '0',
							Z => c2_2_in
							);
	Add_Sub_Poly3: Add_Sub_Poly
					port map(
							A => c2_2,
							B => m_1,
							ADD_SUB => '0',
							Z => c2_3_in
							);							

	Encoder1: Encode
				port map(
						M => m_0,
						Z => m_1_in
						);
						
	Gauss_Sampler_Poly1: Gauss_Sampler_Poly
					generic map(
								LEN	=> DEGREE_F,
								SEED => 0
								)
					port map(
							CLK => CLK,
							RESET => RESET,
							Z => int_e1
							);	
							
	Gauss_Sampler_Poly2: Gauss_Sampler_Poly
					generic map(
								LEN	=> DEGREE_F,
								SEED => 1
								)
					port map(
							CLK => CLK,
							RESET => RESET,
							Z => int_e2 
							);
							
	Gauss_Sampler_Poly3: Gauss_Sampler_Poly
					generic map(
								LEN	=> DEGREE_F,
								SEED => 2
								)
					port map(
							CLK => CLK,
							RESET => RESET,
							Z =>  int_e3
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
				c1_0	<= A;
				c2_0	<= P;
				m_0		<= M;
			end if;
			
			if load_1 = '1' then
				c1_1	<= c1_1_in;
				c2_1	<= c2_1_in;
				m_1		<= m_1_in;
			end if;
			
			if load_2 = '1' then
				c1_2	<= c1_2_in;
				c2_2	<= c2_2_in;
			end if;
			
			if load_3 = '1' then
				c2_3	<= c2_3_in;
			end if;
		end if;
	end process;
	
	int_rdy <= int_rdy1 and int_rdy2;
	
	C1 <= c1_2;
	C2 <= c2_3;
	
end Behavioral;

